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
		'children',
		'steps'
	],
	#category : #'GToolkit-Jenkins-CoreAPI'
}

{ #category : #accessing }
JcCoreStage class >> backgroundColorForStatus: aStatus [
	aStatus = 'SUCCESS' ifTrue: [ ^ BrGlamorousColors successBackgroundColor ].
	(#('FAILURE' 'FAILED' 'ERROR') includes: aStatus)
		ifTrue: [ ^ BrGlamorousColors errorBackgroundColor ].
	aStatus = 'UNSTABLE' ifTrue: [ ^ BrGlamorousColors failureBackgroundColor ].
	(#('RUNNING' 'IN_PROGRESS') includes: aStatus)
		ifTrue: [ ^ BrGlamorousColors primaryBorderColor ].
	^ BrGlamorousColors neutralBackgroundColor
]

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

{ #category : #association }
JcCoreStage >> agentStage [
	| current |
	current := self.
	[ current notNil ]
		whileTrue: [ (current name beginsWith: 'Agent (') ifTrue: [ ^ current ].
			current := current parent ].
	^ nil
]

{ #category : #association }
JcCoreStage >> agentTarget [
	| agentName |
	agentName := self agentStage ifNil: [ ^ nil ] ifNotNil: [ :agent | agent name ].
	^ agentName copyFrom: 8 to: agentName size - 1
]

{ #category : #accessing }
JcCoreStage >> allStages [
	| all |
	all := OrderedCollection with: self.
	children do: [ :child | all addAll: child allStages ].
	^ all asArray
]

{ #category : #association }
JcCoreStage >> artifacts [
	| target |
	target := self agentTarget ifNil: [ ^ #() ].
	^ run artifacts select: [ :each | each pathSegments includes: target ]
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
JcCoreStage >> gtArtifactsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Artifacts';
		question: 'Which archived files belong to the agent that ran this stage?';
		priority: 14;
		items: [ self artifacts ];
		column: 'File'
			text: [ :artifact | artifact name ]
			width: 250;
		column: 'Path' text: [ :artifact | artifact path ]
]

{ #category : #views }
JcCoreStage >> gtChildrenFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Stages';
		question: 'Which stages belong to this stage or parallel branch?';
		priority: 20;
		items: [ self children ];
		column: 'Status'
			icon: [ :stage | stage statusIcon ]
			width: 50;
		column: 'Stage' text: [ :stage | stage name ];
		column: 'Duration' text: [ :stage | stage durationText ]
]

{ #category : #printing }
JcCoreStage >> gtDisplayOn: aStream [
	aStream nextPutAll: self name
]

{ #category : #views }
JcCoreStage >> gtProblematicTestsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Failed examples';
		question: 'Which tests failed or were skipped in this stage?';
		priority: 12;
		items: [ self testCases ];
		column: 'Status'
			icon: [ :case | case statusIcon ]
			width: 50;
		column: 'Class' text: [ :case | case shortClassName ];
		column: 'Test' text: [ :case | case name ]
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

{ #category : #views }
JcCoreStage >> gtStepsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Steps';
		question: 'Which steps did this stage run?';
		priority: 10;
		items: [ self steps ];
		column: 'Status'
			icon: [ :step | step statusIcon ]
			width: 50;
		column: 'Step' text: [ :step | step name ];
		column: 'Arguments' text: [ :step | step parameterDescription ];
		column: 'Duration'
			text: [ :step | step durationText ]
			width: 100;
		actionButtonIcon: BrGlamorousVectorIcons refresh
			tooltip: 'Refresh steps'
			action: [ :button :tab | 
				self refreshSteps.
				tab viewContentElement phlow update ]
]

{ #category : #views }
JcCoreStage >> gtTestSuitesFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Executed suites';
		question: 'Which JUnit suites ran in this stage and how long did they take?';
		priority: 11;
		items: [ self testSuites
				asSortedCollection: [ :a :b | a durationSeconds >= b durationSeconds ] ];
		column: 'Suite' text: [ :suite | suite name ];
		column: 'Duration'
			text: [ :suite | suite durationText ]
			width: 100
]

{ #category : #accessing }
JcCoreStage >> id [
	^ rawData at: 'id' ifAbsent: [ '' ]
]

{ #category : #tests }
JcCoreStage >> includesStageNames: names [
	| agent |
	(names includes: self name) ifFalse: [ ^ false ].
	agent := self agentStage.
	^ agent isNil or: [ names includes: agent name ]
]

{ #category : #tests }
JcCoreStage >> includesTestCase: aTestCase [
	^ self includesStageNames: aTestCase stageNames
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
JcCoreStage >> refreshSteps [
	| response newSteps |
	response := [ run getJsonAtNodeId: self id suffix: #('wfapi' 'describe') ]
			on: ZnHttpUnsuccessful
			do: [ :error | error response code = 404 ifTrue: [ Dictionary new ] ifFalse: [ error pass ] ].
	newSteps := ((response ifNil: [ Dictionary new ])
			at: 'stageFlowNodes'
			ifAbsent: [ #() ]) collect: [ :each | JcCoreStep stage: self rawData: each ].
	steps := newSteps.
	^ steps
]

{ #category : #views }
JcCoreStage >> resultBackgroundColor [
	^ self class backgroundColorForStatus: self status
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

{ #category : #views }
JcCoreStage >> statusIcon [
	^ BlElement new
		geometry: BlCircleGeometry new;
		background: self resultBackgroundColor;
		size: 10 @ 10
]

{ #category : #accessing }
JcCoreStage >> steps [
	^ steps ifNil: [ self refreshSteps ]
]

{ #category : #association }
JcCoreStage >> testCases [
	^ run problematicTests select: [ :each | self includesTestCase: each ]
]

{ #category : #tests }
JcCoreStage >> testDurationSeconds [
	^ self testSuites inject: 0 into: [ :sum :each | sum + each durationSeconds ]
]

{ #category : #tests }
JcCoreStage >> testSuites [
	^ run testSuitesForStage: self
]

{ #category : #accessing }
JcCoreStage >> type [
	^ rawData at: 'type' ifAbsent: [ 'STAGE' ]
]
