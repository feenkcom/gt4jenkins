Class {
	#name : #JcPipelineNode,
	#superclass : #JcModelElement,
	#instVars : [
		'parentRun',
		'allRawTests'
	],
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanRestImplPipeline'
}

{ #category : #accessing }
JcPipelineNode >> addRawTest: aDictionary [
	allRawTests add: aDictionary
]

{ #category : #accessing }
JcPipelineNode >> allCasesSize [
	^ (self allTests flatCollect: [:c | c allCases]) size
]

{ #category : #accessing }
JcPipelineNode >> allRawTests [
	^ allRawTests
]

{ #category : #accessing }
JcPipelineNode >> allTests [
	allRawTests := parentRun allTests at: self id ifAbsent:[nil]. "this will trigger a get in the parent to cache all test results"
	allRawTests ifNil: [^ OrderedCollection new].
	^ theModelBuilder modelFrom: allRawTests className: 'IoJenkinsBlueoceanServiceEmbeddedRestJunit.BlueJUnitStageTestResult'
]

{ #category : #accessing }
JcPipelineNode >> duration [
	^ Duration milliSeconds: (rawData at: 'durationInMillis' )
]

{ #category : #accessing }
JcPipelineNode >> failedTests [
	|allFailed|
	allFailed := OrderedCollection new.
	parentRun tests ifNotNil: [
		allFailed := parentRun tests select: [:each | each isFailed].
		allFailed := allFailed select: [:t | t testNameParsed size = 4 and: [(t testNameParsed at: 3) trimmed asSymbol = self name asSymbol]]].
	^ allFailed
]

{ #category : #accessing }
JcPipelineNode >> gtAllTestsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Tests' translated;
		priority: 60;
		items: [ self allTests ];
		column: '' translated
			text: [ :eachItem :eachIndex | eachIndex asRopedText foreground: Color gray ]
			width: 30;
		column: '' translated
			do: [ :column | 
				column
					stencil: [ :each | 
						BlElement new
							geometry: BlCircleGeometry new;
							background: each statusBackgroundColor;
							size: 10 @ 10;
							constraintsDo: [ :c | c linear horizontal alignCenter ];
							margin: (BlInsets
									top: 5
									left: 5
									bottom: 5
									right: 5) ];
					width: 20 ];
		column: 'Package' translated
			text: [ :eachItem | eachItem testClassName ]
			weight: 3;
		column: 'Tests' translated
			text: [ :eachItem | eachItem allCases size ]
			width: 65;
		column: 'Duration' translated
			text: [ :eachItem | eachItem duration ]
			width: 60
]

{ #category : #accessing }
JcPipelineNode >> gtDisplayOn: stream [
	stream nextPutAll: (self name)
]

{ #category : #'gt - extensions' }
JcPipelineNode >> gtExamplesDurationFor: aView [
	<gtView>
	^ aView explicit
		title: 'Durations';
		priority: 80;
		tooltip: 'Test execution durations (size = duration)';
		stencil: [ | sortedTests |
			sortedTests := (self allTests reject: [ :e | e duration isZero ])
					sorted: [ :a :b | a duration > b duration ].

			GtNestedRectangleTreeMap new
				roots: sortedTests;
				leaves: [ :aNode | 
					(aNode allCases reject: [ :e | e duration isZero ])
						sorted: [ :a :b | a duration > b duration ] ];
				leavesSize: [ :aNode | aNode duration ];
				containerElement: [ :anElement :aNodeContext | 
					| aLabel |
					anElement background: Color white.
					anElement
						border: (BlBorder paint: BrGlamorousColors disabledButtonBorderColor width: 2).
					anElement padding: (BlInsets all: 2) + (BlInsets top: 10).

					anElement
						addChild: (aLabel := BrLabel new
									text: aNodeContext model testClassName;
									aptitude: (BrGlamorousLabelAptitude new
											fontSize: 8;
											foreground: Color black);
									visibility: BlVisibility hidden;
									constraintsDo: [ :c | c ignoreByLayout ]).

					anElement
						addAptitude: (BrStyleCommonAptitude new
								default: [ :aStyle |  ];
								hovered: [ :aStyle | 
									aStyle
										do: [ :aWidget | aLabel visibility: BlVisibility visible ]
										after: [ :aWidget | aLabel visibility: BlVisibility hidden ] ]) ];
				leafElement: [ :anElement :aLeafContext | 
					anElement background: aLeafContext model statusBackgroundColor.
					anElement border: (BlBorder paint: Color white width: 1).
					anElement
						addAptitude: (BrGlamorousWithLabelTooltipAptitude new
								text: aLeafContext model shortClassAndMethodName , ', duration='
										, aLeafContext model duration asString).
					anElement
						when: BlClickEvent
						do: [ :anEvent | anElement phlow spawnObject: aLeafContext model ] ] ]
]

{ #category : #'gt - extensions' }
JcPipelineNode >> gtExamplesTreemapFor: aView [
]

{ #category : #accessing }
JcPipelineNode >> gtFailedTestsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Failed examples' translated;
		priority: 60;
		items: [ self failedTests ];
		column: 'Index' translated
			text: [ :eachItem :eachIndex | eachIndex asRopedText foreground: Color gray ]
			width: 20;
		column: 'Status' translated
			icon: [ :each | 
					BlElement new
						geometry: BlCircleGeometry new;
						background: each statusBackgroundColor;
						size: 10 @ 10 ]
			width: 50;
		column: 'Class' translated
			text: [ :eachItem | eachItem testClassName ]
			width: 250;
		column: 'Method' translated
			text: [ :eachItem | eachItem testMethodName ]
]

{ #category : #accessing }
JcPipelineNode >> gtStepsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Steps' translated;
		priority: 100;
		items: [ self steps ];
		column: 'Status' translated
			icon: [ :each | 
				BrVerticalPane new alignCenter
					addChild: (BlElement new
							background: each resultBackgroundColor;
							size: 16 @ 16)	"geometry: BlCircleGeometry new;" ]
			width: 40;
		column: 'Step' translated
			icon: [ :eachItem | 
				BrExpander new
					vFitContent;
					hMatchParent;
					collapse;
					margin: (BlInsets all: 10);
					aptitude: GtCoderExpanderAptitude new;
					header: [ BrLabel new
							aptitude: BrGlamorousLabelAptitude;
							text: eachItem gtDisplayString ];
					content: [ | container |
						container := BrFrame new
								vExact: 400;
								hMatchParent;
								aptitude: BrGlamorousWithVerticalResizerAptitude;
								addChild: (eachItem gtLogFor: GtPhlowEmptyView new) asElement matchParent ] ]
			weight: 1
]

{ #category : #testing }
JcPipelineNode >> gtTestingSteps [
	^ self steps select: [ :aStep |
		aStep isGtInstallerTestRun ]
]

{ #category : #'gt - extensions' }
JcPipelineNode >> gtViewVmExecutionStatisticsReportsFor: aView [
	<gtView>
	
	^ aView forward 
		title: 'VM GC Statistics';
		object: [ self gtVmExecutionStatisticsReports ];
		view: #gtViewGcStatisticsFor: 
]

{ #category : #testing }
JcPipelineNode >> gtVmExecutionStatisticsReports [
	^ GtVmExecutionStatisticsReportsGroup withAll: (self gtTestingSteps 
		flatCollect: [ :aStep |
			aStep gtVmExecutionStatisticsReports ]) 
]

{ #category : #accessing }
JcPipelineNode >> id [ 
	^ rawData at:'id'
]

{ #category : #testing }
JcPipelineNode >> isGtTestNode [
	^ {'Test MacOS' . 'Test Linux' . 'Test Windows'} anySatisfy: [ :aLabel |
	self name beginsWith: aLabel ]
]

{ #category : #accessing }
JcPipelineNode >> name [
	^ rawData at: 'displayName'
]

{ #category : #accessing }
JcPipelineNode >> nextStagesIds [
	^ (rawData at: 'edges') collect: [:e | e at: 'id']
]

{ #category : #accessing }
JcPipelineNode >> parentRun [
	^ parentRun
]

{ #category : #accessing }
JcPipelineNode >> parentRun: aParentRun [
	parentRun := aParentRun
]

{ #category : #accessing }
JcPipelineNode >> result [
	^ rawData at: 'result'
]

{ #category : #accessing }
JcPipelineNode >> resultBackgroundColor [
	^ JcJenkinsClient backgroundColorForStatus: self result
]

{ #category : #accessing }
JcPipelineNode >> steps [
	^ (super linksClientFor: 'steps') execute
]
