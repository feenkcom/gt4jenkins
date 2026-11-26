"
{{gtClass:JcCoreStage}} represents a Pipeline stage or parallel branch in a {{gtClass:JcCoreRun}}. It keeps the stage hierarchy returned by the Pipeline Graph View endpoint, while a flat Stage View response can also create standalone stages.
"
Class {
	#name : #JcCoreStage,
	#superclass : #Object,
	#instVars : [
		'run',
		'parent',
		'rawData',
		'children'
	],
	#category : #'GToolkit-Jenkins-CoreAPI'
}

{ #category : #'instance creation' }
JcCoreStage class >> run: aRun parent: aParent rawData: aDictionary [
	^ self new
		run: aRun
		parent: aParent
		rawData: aDictionary
]

{ #category : #graph }
JcCoreStage >> addEdgesTo: aCollection [
	| sources |
	self isParallelBlock
		ifTrue: [ children
				do: [ :each | 
					each addEdgesTo: aCollection.
					aCollection add: self -> each ].
			^ self ].
	sources := {self}.
	children
		do: [ :each | 
			each addEdgesTo: aCollection.
			sources do: [ :source | aCollection add: source -> each ].
			sources := each exitStages ]
]

{ #category : #accessing }
JcCoreStage >> allStages [
	| all |
	all := OrderedCollection with: self.
	children do: [ :child | all addAll: child allStages ].
	^ all asArray
]

{ #category : #views }
JcCoreStage >> cardElement [
	| container labels duration |
	container := BrHorizontalPane new
			hExact: 200;
			vFitContent;
			aptitude: BrShadowAptitude;
			clipChildren: false;
			margin: (BlInsets all: 10);
			background: Color white;
			zIndex: 1;
			when: BlClickEvent do: [ :event | event target phlow spawnObject: self ].
	labels := BrVerticalPane new
			hMatchParent;
			vFitContent;
			clipChildren: false.
	labels
		addChild: (BrLabel new
				margin: (BlInsets all: 5);
				text: self name asRopedText;
				aptitude: BrGlamorousLabelAptitude).
	duration := self durationText.
	duration isEmpty
		ifFalse: [ labels
				addChild: (BrLabel new
						margin: (BlInsets
								top: 0
								left: 5
								bottom: 5
								right: 5);
						text: duration asRopedText;
						aptitude: (BrGlamorousLabelAptitude new foreground: Color gray)) ].
	container
		addChild: (BrVerticalPane new
				vMatchParent;
				hExact: 15;
				background: self resultBackgroundColor);
		addChild: labels.
	^ container
]

{ #category : #accessing }
JcCoreStage >> children [
	^ children
]

{ #category : #accessing }
JcCoreStage >> durationMillis [
	^ rawData
		at: 'totalDurationMillis'
		ifAbsent: [ rawData at: 'durationMillis' ifAbsent: [ nil ] ]
]

{ #category : #accessing }
JcCoreStage >> durationText [
	| milliseconds |
	milliseconds := self durationMillis.
	^ milliseconds
		ifNil: [ '' ]
		ifNotNil: [ (milliseconds max: 0) milliSeconds humanReadablePrintString ]
]

{ #category : #graph }
JcCoreStage >> exitStages [
	children isEmpty ifTrue: [ ^ {self} ].
	^ self isParallelBlock
		ifTrue: [ children flatCollect: [ :each | each exitStages ] ]
		ifFalse: [ children last exitStages ]
]

{ #category : #views }
JcCoreStage >> gtChildrenFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Stages';
		question: 'Which stages belong to this stage or parallel branch?';
		priority: 20;
		items: [ self children ];
		column: 'Status' text: [ :stage | stage status ];
		column: 'Stage' text: [ :stage | stage name ];
		column: 'Duration' text: [ :stage | stage durationText ]
]

{ #category : #printing }
JcCoreStage >> gtDisplayOn: aStream [
	aStream nextPutAll: self name
]

{ #category : #views }
JcCoreStage >> gtRawDataFor: aView [
	<gtView>
	^ aView forward
		title: 'Raw data';
		question: 'Which stage fields did Jenkins return?';
		priority: 100;
		object: [ self rawData ];
		view: #gtTreeFor:context:
]

{ #category : #accessing }
JcCoreStage >> id [
	^ rawData at: 'id' ifAbsent: [ '' ]
]

{ #category : #testing }
JcCoreStage >> isParallel [
	^ #('PARALLEL' 'PARALLEL_BLOCK') includes: self type
]

{ #category : #testing }
JcCoreStage >> isParallelBlock [
	^ self type = 'PARALLEL_BLOCK'
]

{ #category : #testing }
JcCoreStage >> isSequential [
	^ rawData at: 'isSequential' ifAbsent: [ true ]
]

{ #category : #accessing }
JcCoreStage >> name [
	^ rawData at: 'name' ifAbsent: [ '' ]
]

{ #category : #accessing }
JcCoreStage >> parent [
	^ parent
]

{ #category : #accessing }
JcCoreStage >> rawData [
	^ rawData
]

{ #category : #accessing }
JcCoreStage >> resultBackgroundColor [
	| state |
	state := self status.
	state = 'SUCCESS' ifTrue: [ ^ BrGlamorousColors successBackgroundColor ].
	(#('FAILURE' 'FAILED' 'ERROR') includes: state)
		ifTrue: [ ^ BrGlamorousColors errorBackgroundColor ].
	state = 'UNSTABLE' ifTrue: [ ^ BrGlamorousColors failureBackgroundColor ].
	^ BrGlamorousColors neutralBackgroundColor
]

{ #category : #accessing }
JcCoreStage >> run [
	^ run
]

{ #category : #initialization }
JcCoreStage >> run: aRun parent: aParent rawData: aDictionary [
	run := aRun.
	parent := aParent.
	rawData := aDictionary.
	children := (rawData at: 'children' ifAbsent: [ #() ])
			collect: [ :each | 
				self class
					run: run
					parent: self
					rawData: each ].
	^ self
]

{ #category : #accessing }
JcCoreStage >> startTimeMillis [
	^ rawData at: 'startTimeMillis' ifAbsent: [ nil ]
]

{ #category : #accessing }
JcCoreStage >> state [
	^ rawData at: 'state' ifAbsent: [ rawData at: 'status' ifAbsent: [ '' ] ]
]

{ #category : #accessing }
JcCoreStage >> status [
	^ self state asUppercase
]

{ #category : #accessing }
JcCoreStage >> type [
	^ rawData at: 'type' ifAbsent: [ 'STAGE' ]
]
