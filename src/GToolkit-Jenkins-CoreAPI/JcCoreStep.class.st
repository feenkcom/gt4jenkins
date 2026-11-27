Class {
	#name : #JcCoreStep,
	#superclass : #Object,
	#instVars : [
		'stage',
		'rawData',
		'log',
		'logOffset'
	],
	#category : #'GToolkit-Jenkins-CoreAPI'
}

{ #category : #'instance creation' }
JcCoreStep class >> stage: aStage rawData: aDictionary [
	^ self new stage: aStage rawData: aDictionary
]

{ #category : #log }
JcCoreStep >> appendLog [
	^ self appendLogText isEmpty not
]

{ #category : #log }
JcCoreStep >> appendLogText [
	| path result |
	path := stage run client jobPathSegmentsForNames: stage run jobNames.
	path add: stage run number asString.
	path addAll: #('execution' 'node').
	path add: self id asString.
	path addAll: #('log' 'logText' 'progressiveText').
	result := [ stage run client
			getProgressiveTextAtPathSegments: path
			start: logOffset ]
			on: ZnHttpUnsuccessful
			do: [ :error | error response code = 404 ifTrue: [ ^ '' ] ifFalse: [ error pass ] ].
	logOffset := result value.
	log := (log ifNil: [ '' ]) , result key.
	^ result key
]

{ #category : #accessing }
JcCoreStep >> durationMillis [
	^ rawData at: 'durationMillis' ifAbsent: [ nil ]
]

{ #category : #accessing }
JcCoreStep >> durationText [
	| milliseconds |
	milliseconds := self durationMillis.
	^ milliseconds
		ifNil: [ '' ]
		ifNotNil: [ (milliseconds max: 0) milliSeconds humanReadablePrintString ]
]

{ #category : #log }
JcCoreStep >> followLogIn: anEditorElement [
	^ self followLogIn: anEditorElement everyMilliseconds: 2000
]

{ #category : #log }
JcCoreStep >> followLogIn: anEditorElement everyMilliseconds: anInteger [
	| process |
	(self isFollowingLogIn: anEditorElement) ifTrue: [ ^ self ].
	anEditorElement scrollToPosition: anEditorElement lineCount.
	process := [ | idle |
		idle := 0.
		[ anEditorElement isAttachedToSceneGraph and: [ idle < 2 ] ]
			whileTrue: [ | chunk |
				(Delay forMilliseconds: anInteger) wait.
				chunk := [ self appendLogText ] on: Error do: [ :error | '' ].
				chunk isEmpty
					ifFalse: [ idle := 0.
						anEditorElement
							enqueueTask: (BlTaskAction new
									action: [ anEditorElement text append: chunk asRopedText.
										anEditorElement scrollToPosition: anEditorElement lineCount ]) ]
					ifTrue: [ [ self refreshStatus ] on: Error do: [ :error | nil ].
						self isInProgress ifFalse: [ idle := idle + 1 ] ] ].
		anEditorElement userData removeKey: #jenkinsLogFollower ifAbsent: [ nil ] ]
			fork.
	anEditorElement userData at: #jenkinsLogFollower put: process
]

{ #category : #printing }
JcCoreStep >> gtDisplayOn: aStream [
	aStream nextPutAll: self name.
	self parameterDescription isEmpty
		ifFalse: [ aStream
				nextPutAll: ' - ';
				nextPutAll: self parameterDescription ]
]

{ #category : #views }
JcCoreStep >> gtLogFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Log';
		question: 'What did this step write to the console?';
		priority: 10;
		aptitude: BrGlamorousCodeEditorAptitude;
		text: [ self logText ];
		actionButtonIcon: BrGlamorousVectorIcons refresh
			tooltip: 'Reload log'
			action: [ :button :tab | 
				self refreshLog.
				tab viewContentElement phlow update ];
		actionButtonIcon: BrGlamorousVectorIcons play
			tooltip: 'Follow the log while the step runs (press again to stop)'
			action: [ :button :tab | 
				| editor |
				editor := tab viewContentElement withAllChildrenBreadthFirst
						detect: [ :each | each isKindOf: BrEditor ]
						ifNone: [ nil ].
				editor
					ifNotNil: [ (self isFollowingLogIn: editor)
							ifTrue: [ 
								self stopFollowingLogIn: editor. 
								button icon: BrGlamorousVectorIcons play ]
							ifFalse: [ 
								self followLogIn: editor.
								button icon: BrGlamorousVectorIcons stop ] ]
					ifNil: [ button icon: BrGlamorousVectorIcons play ] ]
]

{ #category : #views }
JcCoreStep >> gtRawDataFor: aView [
	<gtView>
	^ aView forward
		title: 'Raw data';
		question: 'Which step fields did Jenkins return?';
		priority: 100;
		object: [ self rawData ];
		view: #gtTreeFor:context:
]

{ #category : #accessing }
JcCoreStep >> id [
	^ rawData at: 'id' ifAbsent: [ '' ]
]

{ #category : #log }
JcCoreStep >> isFollowingLogIn: anEditorElement [
	^ (anEditorElement userData at: #jenkinsLogFollower ifAbsent: [ nil ])
		ifNil: [ false ]
		ifNotNil: [ :process | process isTerminated not ]
]

{ #category : #log }
JcCoreStep >> isInProgress [
	^ #('IN_PROGRESS' 'RUNNING' 'PAUSED_PENDING_INPUT') includes: self status
]

{ #category : #log }
JcCoreStep >> logText [
	^ log ifNil: [ self refreshLog ]
]

{ #category : #accessing }
JcCoreStep >> name [
	^ rawData at: 'name' ifAbsent: [ '' ]
]

{ #category : #accessing }
JcCoreStep >> parameterDescription [
	^ (rawData at: 'parameterDescription' ifAbsent: [ nil ]) ifNil: [ '' ]
]

{ #category : #accessing }
JcCoreStep >> rawData [
	^ rawData
]

{ #category : #log }
JcCoreStep >> refreshLog [
	log := ''.
	logOffset := 0.
	self appendLog.
	^ log
]

{ #category : #log }
JcCoreStep >> refreshStatus [
	| response |
	response := [ stage run getJsonAtNodeId: self id suffix: #('wfapi' 'describe') ]
			on: ZnHttpUnsuccessful
			do: [ :error | error response code = 404 ifTrue: [ ^ self status ] ifFalse: [ error pass ] ].
	((response ifNil: [ Dictionary new ]) at: 'status' ifAbsent: [ nil ])
		ifNotNil: [ :value | rawData at: 'status' put: value ].
	^ self status
]

{ #category : #views }
JcCoreStep >> resultBackgroundColor [
	^ JcCoreStage backgroundColorForStatus: self status
]

{ #category : #accessing }
JcCoreStep >> stage [
	^ stage
]

{ #category : #initialization }
JcCoreStep >> stage: aStage rawData: aDictionary [
	stage := aStage.
	rawData := aDictionary.
	log := nil.
	logOffset := 0
]

{ #category : #accessing }
JcCoreStep >> status [
	^ (rawData at: 'status' ifAbsent: [ '' ]) asUppercase
]

{ #category : #views }
JcCoreStep >> statusIcon [
	^ BlElement new
		geometry: BlCircleGeometry new;
		background: self resultBackgroundColor;
		size: 10 @ 10
]

{ #category : #log }
JcCoreStep >> stopFollowingLogIn: anEditorElement [
	(anEditorElement userData removeKey: #jenkinsLogFollower ifAbsent: [ nil ])
		ifNotNil: [ :process | process terminate ]
]
