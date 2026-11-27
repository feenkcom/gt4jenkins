Class {
	#name : #JcCoreStep,
	#superclass : #Object,
	#instVars : [
		'stage',
		'rawData',
		'log'
	],
	#category : #'GToolkit-Jenkins-CoreAPI'
}

{ #category : #accessing }
JcCoreStep class >> plainTextFromLog: aString [
	| text |
	text := aString copyWithRegex: '<[^>]*>' matchesReplacedWith: ''.
	#('&lt;' '<' '&gt;' '>' '&quot;' '"' '&#39;' '''' '&amp;' '&')
		pairsDo: [ :entity :character | text := text copyReplaceAll: entity with: character ].
	^ text
]

{ #category : #'instance creation' }
JcCoreStep class >> stage: aStage rawData: aDictionary [
	^ self new stage: aStage rawData: aDictionary
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
			tooltip: 'Refresh log'
			action: [ :button :tab | 
				self refreshLog.
				tab viewContentElement phlow update ]
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

{ #category : #accessing }
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

{ #category : #accessing }
JcCoreStep >> refreshLog [
	| response text |
	response := [ stage run getJsonAtNodeId: self id suffix: #('wfapi' 'log') ]
			on: ZnHttpUnsuccessful
			do: [ :error | error response code = 404 ifTrue: [ nil ] ifFalse: [ error pass ] ].
	text := response
			ifNil: [ '' ]
			ifNotNil: [ response at: 'text' ifAbsent: [ '' ] ].
	log := self class plainTextFromLog: text.
	^ log
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
	log := nil
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
