Class {
	#name : #JcPipelineRun,
	#superclass : #JcModelElement,
	#instVars : [
		'tests',
		'parentBranchName',
		'allTests',
		'nodesDictionary'
	],
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanRestImplPipeline'
}

{ #category : #accessing }
JcPipelineRun >> allTests [
	|client stageId allTestsResult|
	allTests ifNil: [
		client := (super urlClientFor: self allTestsURL).
		client modelBuilder jenkinsClient setBasicAuth.
		allTestsResult := client execute].
		
		allTestsResult ifNotNil: [
			allTests := Dictionary new.
			allTestsResult rawSuites collect: [ :suite | 
				|enclosingBlocksArray|
				enclosingBlocksArray := (suite at: 'enclosingBlocks').
				enclosingBlocksArray ifNotEmpty: [
					stageId := enclosingBlocksArray first.
					allTests at: stageId ifAbsentPut: OrderedCollection new.
						(allTests at: stageId) add: suite]]].
	allTests ifNil: [ ^ Dictionary new].
	^ allTests.
]

{ #category : #accessing }
JcPipelineRun >> allTestsURL [
		^ '/job/', (parentBranchName copyReplaceAll: '/' with: '/job/'), '/' , (rawData at: 'id'), '/testReport/api/json'
]

{ #category : #accessing }
JcPipelineRun >> duration [
	^ ((rawData at: 'durationInMillis')  asNumber milliSeconds roundTo: 1 second) humanReadablePrintString
]

{ #category : #accessing }
JcPipelineRun >> gtDisplayOn: stream [
	stream nextPutAll: (rawData at: 'id')
]

{ #category : #accessing }
JcPipelineRun >> gtNodesFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Nodes' translated;
		priority: 1;
		items: [ self nodes sort: [ :a :b | a id asInteger < b id asInteger ] ];
		column: 'Status' translated
			icon: [ :each | 
					BlElement new
						geometry: BlCircleGeometry new;
						background: each resultBackgroundColor;
						size: 10 @ 10 ]
			width: 50;
		column: 'Result' translated text: [ :each | each result ] width: 70;
		column: 'Item' translated
			text: [ :each | each gtDisplayText ]
			width: 200;
		column: 'Duration' translated
			text: [ :each | each duration ]
			width: 200
]

{ #category : #accessing }
JcPipelineRun >> gtStagesMapFor: aView [
	<gtView>
	^ aView mondrian
		title: 'Stages map' translated;
		priority: 55;
		painting: [ :mondrian | 
			| allNodes |
			allNodes := self nodes.
			mondrian nodes
				shape: [ :aStage | 
					| container statusColor labelContainer duration |
					statusColor := aStage resultBackgroundColor.
					container := BrHorizontalPane new
							hExact: 200;
							vFitContent;
							aptitude: BrShadowAptitude;
							clipChildren: false;
							margin: (BlInsets all: 10);
							background: Color white;
							zIndex: 1;
							when: BlClickEvent do: [ :e | e target phlow spawnObject: aStage ].
					labelContainer := BrVerticalPane new
							hMatchParent;
							vFitContent;
							clipChildren: false.

					labelContainer
						addChild: (BrEditor new
								text: aStage name asRopedText;
								aptitude: BrGlamorousRegularEditorAptitude).
					duration := aStage duration.
					duration < 1 second
						ifFalse: [ labelContainer
								addChild: (BrLabel new
										margin: (BlInsets top: 0 left: 5 bottom: 5 right: 5);
										text: duration gtHumanReadableString asRopedText;
										aptitude: (BrGlamorousLabelAptitude new foreground: Color gray)) ].	"examplesSize := aStage allCasesSize.
		examplesSize > 0
			ifTrue: [ labelContainer
					addChild: (BrLabel new
							text: aStage allCasesSize asString , ' tests';
							aptitude: (BrGlamorousLabelAptitude new foreground: Color gray)) ]."
					container
						addChild: (BrVerticalPane new
								vMatchParent;
								hExact: 15;
								background: statusColor);
						addChild: labelContainer ];
				with: allNodes.
			mondrian edges
				shape: [ BlSigmoidElement new
						zIndex: 0;
						beVertical;
						bendingPoint: 0.3;
						sharpness: 0.1;
						border: (BlBorder paint: (Color gray alpha: 0.2) width: 2) ];
				fromCenterBottom;
				toCenterTop;
				connectFrom: #yourself
					toAll: [ :each | 
						| pN |
						pN := each nextStagesIds.
						allNodes
							select: [ :node | pN anySatisfy: [ :stageID | stageID = node id ] ] ].
			mondrian layout dominanceTree
				"nodesAlignment: GtGradTreeNodesCenterAlignment new;"
				levelDistance: 20;
				nodeDistance: 20.
			mondrian ]
]

{ #category : #accessing }
JcPipelineRun >> gtTestsFor: aView [
	<gtView>
	(rawData at: 'state') = 'RUNNING'
		ifTrue: [ ^ aView empty ].
	^ aView columnedList
		title: (rawData at: 'runSummary') translated;
		priority: 50;
		items: [ self tests ];
		column: 'Status' translated
			icon: [ :each | 
					BlElement new
						geometry: BlCircleGeometry new;
						background: each statusBackgroundColor;
						size: 10 @ 10 ]
			width: 50;
		column: 'Status' translated
			text: [ :eachTest | eachTest status ]
			width: 70;
		column: 'Class' translated
			text: [ :eachTest | eachTest testClassName ]
			width: 250;
		column: 'Method' translated
			text: [ :eachTest | eachTest testMethodName ];
		column: 'Stage' translated
			text: [ :eachTest | eachTest fullStageName ]
]

{ #category : #accessing }
JcPipelineRun >> nodes [
	nodesDictionary
		ifNil: [ nodesDictionary := Dictionary new.
			(self linksClientFor: 'nodes') execute
				do: [ :each | 
					nodesDictionary 
						at: each id 
						put: (each parentRun: self) ] ].
	^ nodesDictionary values
]

{ #category : #accessing }
JcPipelineRun >> nodesDictionary [
	^ nodesDictionary
]

{ #category : #accessing }
JcPipelineRun >> parentBranchName: aBranchName [
	parentBranchName := aBranchName
]

{ #category : #accessing }
JcPipelineRun >> result [
	^ rawData at: 'result'
]

{ #category : #accessing }
JcPipelineRun >> resultBackgroundColor [
	^ JcJenkinsClient backgroundColorForStatus: self result
]

{ #category : #accessing }
JcPipelineRun >> startTime [
	|st|
	st := DateAndTime fromString: (rawData at: 'startTime').
	st := st asLocal.
	^ String streamContents: [:s | st printSeparateDateAndTimeOn: s]
	
]

{ #category : #accessing }
JcPipelineRun >> tests [
	tests ifNil: [ tests := ((super linksClientFor: 'tests') execute)].
	tests ifNil: [ ^ OrderedCollection new].
	^ tests
]
