"
{{gtClass:JcCoreRun}} represents a Jenkins build from {{gtClass:JcCoreClient}}. It retains the build summary and lazily loads details, archived {{gtClass:JcCoreArtifact}} objects, {{gtClass:JcCoreStage}} objects, and JUnit test results. Stage objects use the Pipeline Graph View tree when available, with a Stage View fallback. Use {{gtSymbol:refreshStages}} and {{gtSymbol:refreshProblematicTests}} to update those cached views.
"
Class {
	#name : #JcCoreRun,
	#superclass : #Object,
	#instVars : [
		'client',
		'jobNames',
		'rawData',
		'details',
		'artifacts',
		'stages',
		'rootStages',
		'stageTreeAvailable',
		'problematicTests'
	],
	#category : #'GToolkit-Jenkins-CoreAPI'
}

{ #category : #'instance creation' }
JcCoreRun class >> client: aClient jobNames: names rawData: aDictionary [
	^ self new
		client: aClient
		jobNames: names
		rawData: aDictionary
]

{ #category : #accessing }
JcCoreRun >> artifactContentsFor: anArtifact [
	| relativePath path |
	relativePath := anArtifact at: 'relativePath' ifAbsent: [ ^ nil ].
	path := client jobPathSegmentsForNames: jobNames.
	path add: self number asString.
	path add: 'artifact'.
	(relativePath findTokens: '/') do: [ :segment | path add: segment ].
	^ [ client getAtPathSegments: path ]
		on: ZnHttpUnsuccessful
		do: [ :error | error response code = 404 ifTrue: [ nil ] ifFalse: [ error pass ] ]
]

{ #category : #artifacts }
JcCoreRun >> artifactUrlFor: anArtifact [
	| path url |
	path := anArtifact at: 'relativePath' ifAbsent: [ ^ nil ].
	url := client baseUrl copy.
	(client jobPathSegmentsForNames: jobNames)
		do: [ :segment | url addPathSegment: segment ].
	url addPathSegment: self number asString.
	url addPathSegment: 'artifact'.
	(path findTokens: '/') do: [ :segment | url addPathSegment: segment ].
	^ url asString
]

{ #category : #artifacts }
JcCoreRun >> artifacts [
	| path response |
	artifacts
		ifNil: [ path := client jobPathSegmentsForNames: jobNames.
			path add: self number asString.
			response := client
					getJsonAtPathSegments: path
					tree: 'artifacts[fileName,relativePath]'.
			artifacts := (response at: 'artifacts' ifAbsent: [ #() ])
					collect: [ :each | JcCoreArtifact run: self rawData: each ] ].
	^ artifacts
]

{ #category : #accessing }
JcCoreRun >> building [
	^ rawData at: 'building' ifAbsent: [ self detailAt: 'building' ]
]

{ #category : #initialization }
JcCoreRun >> client: aClient jobNames: names rawData: aDictionary [
	client := aClient.
	jobNames := names asArray.
	rawData := aDictionary.
	details := nil.
	artifacts := nil.
	stages := nil.
	rootStages := nil.
	stageTreeAvailable := nil.
	problematicTests := nil.
	^ self
]

{ #category : #details }
JcCoreRun >> detailAt: aKey [
	^ self details at: aKey ifAbsent: [ nil ]
]

{ #category : #details }
JcCoreRun >> details [
	| path |
	details
		ifNil: [ path := client jobPathSegmentsForNames: jobNames.
			path add: self number asString.
			details := client
					getJsonAtPathSegments: path
					tree: 'number,result,timestamp,duration,url,building' ].
	^ details
]

{ #category : #accessing }
JcCoreRun >> duration [
	^ rawData at: 'duration' ifAbsent: [ self detailAt: 'duration' ]
]

{ #category : #accessing }
JcCoreRun >> durationText [
	| elapsed milliseconds |
	self building = true
		ifTrue: [ elapsed := self startTime ifNil: [ ^ 'RUNNING' ].
			^ (DateAndTime now - elapsed) humanReadablePrintString ].
	milliseconds := self duration.
	^ milliseconds
		ifNil: [ '' ]
		ifNotNil: [ milliseconds milliSeconds humanReadablePrintString ]
]

{ #category : #'gt - views' }
JcCoreRun >> gtArtifactsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Artifacts';
		question: 'Which files did this Jenkins build archive?';
		priority: 40;
		items: [ self artifacts ];
		column: 'Path' text: [ :artifact | artifact path ];
		column: 'File' text: [ :artifact | artifact name ];
		column: 'Download URL' text: [ :artifact | artifact url ifNil: [ '' ] ]
]

{ #category : #'gt - views' }
JcCoreRun >> gtDetailsFor: aView [
	<gtView>
	^ aView forward
		title: 'Details';
		question: 'What is the current state and timing of this Jenkins build?';
		priority: 20;
		object: [ self details ];
		view: #gtTreeFor:context:
]

{ #category : #printing }
JcCoreRun >> gtDisplayOn: aStream [
	aStream
		nextPut: $#;
		nextPutAll: self number asString
]

{ #category : #views }
JcCoreRun >> gtProblematicTestsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Problematic tests';
		question: 'Which JUnit tests failed or were skipped in this build?';
		priority: 50;
		items: [ self problematicTests ];
		column: 'Status' text: [ :case | case at: 'status' ifAbsent: [ '' ] ];
		column: 'Class' text: [ :case | case at: 'className' ifAbsent: [ '' ] ];
		column: 'Test' text: [ :case | case at: 'name' ifAbsent: [ '' ] ];
		actionButtonIcon: BrGlamorousVectorIcons refresh
			tooltip: 'Refresh tests'
			action: [ :button :tab | 
				self refreshProblematicTests.
				tab viewContentElement phlow update ]
]

{ #category : #'gt - views' }
JcCoreRun >> gtRawDataFor: aView [
	<gtView>
	^ aView forward
		title: 'Raw data';
		question: 'What summary JSON data created this Jenkins build?';
		priority: 90;
		object: [ self rawData ];
		view: #gtTreeFor:context:
]

{ #category : #views }
JcCoreRun >> gtStagesFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Stages';
		question: 'Which stages did this Jenkins Pipeline build run?';
		priority: 30;
		items: [ self stages ];
		column: 'Status' text: [ :stage | stage status ];
		column: 'Stage' text: [ :stage | stage name ];
		column: 'Parent'
			text: [ :stage | stage parent ifNil: [ '' ] ifNotNil: [ stage parent name ] ];
		column: 'Duration' text: [ :stage | stage durationText ];
		actionButtonIcon: BrGlamorousVectorIcons refresh
			tooltip: 'Refresh stages'
			action: [ :button :tab | 
				self refreshStages.
				tab viewContentElement phlow update ]
]

{ #category : #views }
JcCoreRun >> gtStagesMapFor: aView [
	<gtView>
	^ aView mondrian
		title: 'Stages map';
		question: 'How do the stages and parallel branches of this build connect?';
		priority: 25;
		painting: [ :mondrian | 
			| edges |
			edges := self stageEdges.
			mondrian nodes
				shape: [ :stage | stage cardElement ];
				with: self stages.
			mondrian edges
				shape: [ :edge | 
					BlSigmoidElement new
						zIndex: 0;
						beVertical;
						bendingPoint: 0.3;
						sharpness: 0.1;
						border: (BlBorder paint: (Color gray alpha: 0.2) width: 2) ];
				fromCenterBottom;
				toCenterTop;
				connect: edges
					from: #key
					to: #value.
			edges isEmpty
				ifTrue: [ mondrian layout horizontal ]
				ifFalse: [ mondrian layout dominanceTree
						nodesAlignment: GtGradTreeNodesCenterAlignment new;
						levelDistance: 20;
						nodeDistance: 20 ] ];
		actionButtonIcon: BrGlamorousVectorIcons refresh
			tooltip: 'Refresh stages'
			action: [ :button :tab | 
				self refreshStages.
				tab viewContentElement phlow update ]
]

{ #category : #accessing }
JcCoreRun >> hasStageTree [
	self rootStages.
	^ stageTreeAvailable == true
]

{ #category : #accessing }
JcCoreRun >> number [
	^ rawData at: 'number'
]

{ #category : #accessing }
JcCoreRun >> problematicTests [
	^ problematicTests ifNil: [ self refreshProblematicTests ]
]

{ #category : #accessing }
JcCoreRun >> rawData [
	^ rawData
]

{ #category : #accessing }
JcCoreRun >> refreshProblematicTests [
	| path response cases newTests |
	self building = true
		ifTrue: [ problematicTests := #().
			^ problematicTests ].
	path := client jobPathSegmentsForNames: jobNames.
	path add: self number asString.
	path add: 'testReport'.
	path add: 'api'.
	path add: 'json'.
	response := [ client
			getJsonAtPathSegments: path
			query: (Dictionary new
					at: 'tree' put: 'suites[cases[className,name,status]]';
					yourself) ]
			on: ZnHttpUnsuccessful
			do: [ :error | error response code = 404 ifTrue: [ Dictionary new ] ifFalse: [ error pass ] ].
	cases := (response at: 'suites' ifAbsent: [ #() ])
			flatCollect: [ :suite | suite at: 'cases' ifAbsent: [ #() ] ].
	newTests := cases
			select: [ :each | 
				#('FAILED' 'REGRESSION' 'SKIPPED')
					includes: (each at: 'status' ifAbsent: [ '' ]) ].
	problematicTests := newTests.
	^ problematicTests
]

{ #category : #accessing }
JcCoreRun >> refreshStages [
	| path graph fallback rootData newRoots newStages |
	path := client jobPathSegmentsForNames: jobNames.
	path add: self number asString.
	graph := [ client
			getJsonAtPathSegments: (path copy
					add: 'stages';
					add: 'tree';
					yourself) ]
			on: ZnHttpUnsuccessful
			do: [ :error | error response code = 404 ifTrue: [ nil ] ifFalse: [ error pass ] ].
	rootData := graph
			ifNil: [ fallback := [ client
						getJsonAtPathSegments: (path copy
								add: 'wfapi';
								add: 'describe';
								yourself) ]
						on: ZnHttpUnsuccessful
						do: [ :error | error response code = 404 ifTrue: [ Dictionary new ] ifFalse: [ error pass ] ].
				fallback at: 'stages' ifAbsent: [ #() ] ]
			ifNotNil: [ (graph at: 'data' ifAbsent: [ Dictionary new ])
					at: 'stages'
					ifAbsent: [ #() ] ].
	newRoots := rootData
			collect: [ :each | 
				JcCoreStage
					run: self
					parent: nil
					rawData: each ].
	newStages := newRoots flatCollect: [ :each | each allStages ].
	stageTreeAvailable := graph notNil.
	rootStages := newRoots.
	stages := newStages.
	^ stages
]

{ #category : #accessing }
JcCoreRun >> result [
	^ rawData at: 'result' ifAbsent: [ self detailAt: 'result' ]
]

{ #category : #accessing }
JcCoreRun >> resultBackgroundColor [
	self building = true ifTrue: [ ^ BrGlamorousColors neutralBackgroundColor ].
	self result = 'SUCCESS' ifTrue: [ ^ BrGlamorousColors successBackgroundColor ].
	self result = 'FAILURE' ifTrue: [ ^ BrGlamorousColors errorBackgroundColor ].
	self result = 'UNSTABLE' ifTrue: [ ^ BrGlamorousColors failureBackgroundColor ].
	^ BrGlamorousColors lightBorderColor
]

{ #category : #accessing }
JcCoreRun >> resultText [
	self building = true ifTrue: [ ^ 'RUNNING' ].
	^ self result ifNil: [ 'UNKNOWN' ]
]

{ #category : #accessing }
JcCoreRun >> rootStages [
	rootStages ifNil: [ self refreshStages ].
	^ rootStages
]

{ #category : #accessing }
JcCoreRun >> stageEdges [
	| edges previousExits |
	self hasStageTree ifFalse: [ ^ #() ].
	edges := OrderedCollection new.
	previousExits := #().
	self rootStages
		do: [ :stage | 
			stage addEdgesTo: edges.
			previousExits do: [ :exit | edges add: exit -> stage ].
			previousExits := stage exitStages ].
	^ edges asArray
]

{ #category : #accessing }
JcCoreRun >> stages [
	^ stages ifNil: [ self refreshStages ]
]

{ #category : #accessing }
JcCoreRun >> startTime [
	| milliseconds |
	milliseconds := self timestamp.
	^ milliseconds ifNotNil: [ DateAndTime fromSeconds: milliseconds / 1000 ]
]

{ #category : #accessing }
JcCoreRun >> startTimeText [
	| time |
	time := self startTime.
	^ time
		ifNil: [ '' ]
		ifNotNil: [ String
				streamContents: [ :stream | time asLocal printSeparateDateAndTimeOn: stream ] ]
]

{ #category : #'gt - views' }
JcCoreRun >> statusIcon [
	^ BlElement new
		geometry: BlCircleGeometry new;
		background: self resultBackgroundColor;
		size: 10 @ 10
]

{ #category : #accessing }
JcCoreRun >> timestamp [
	^ rawData at: 'timestamp' ifAbsent: [ self detailAt: 'timestamp' ]
]

{ #category : #accessing }
JcCoreRun >> url [
	^ rawData at: 'url' ifAbsent: [ self detailAt: 'url' ]
]
