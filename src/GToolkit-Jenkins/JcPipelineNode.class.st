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
	| at |
	at := self allTests.
	at isEmpty
		ifTrue: [ ^ aView empty ].
	^ aView columnedList
		title: 'Tests' translated;
		priority: 60;
		items: [ at ];
		column: 'Index' translated
			item: [ :eachItem :eachIndex | eachIndex asRopedText foreground: Color gray ]
			width: 20;
		column: 'Status' translated
			do: [ :column | 
			column
				stencil: [ :each | 
					BlElement new
						geometry: BlCircle new;
						background: each statusBackgroundColor;
						size: 10 @ 10;
						margin:
							(BlInsets
								top: 5
								left: 5
								bottom: 5
								right: 5) ];
				width: 20 ];
		column: 'Package' translated
			text: [ :eachItem | eachItem testClassName ]
			width: 250;
		column: 'Examples' translated
			text: [ :eachItem | eachItem allCases size ]
			width: 50
]

{ #category : #accessing }
JcPipelineNode >> gtDisplayOn: stream [
	stream nextPutAll: (self name)
]

{ #category : #accessing }
JcPipelineNode >> gtFailedTestsFor: aView [
	<gtView>
	| ft |
	ft := self failedTests.
	ft isEmpty
		ifTrue: [ ^ aView empty ].
	^ aView columnedList
		title: 'Failed Examples' translated;
		priority: 60;
		items: [ self failedTests ];
		column: 'Index' translated
			item: [ :eachItem :eachIndex | eachIndex asRopedText foreground: Color gray ]
			width: 20;
		column: 'Status' translated
			icon: [ :each | 
					BlElement new
						geometry: BlCircle new;
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
		priority: 50;
		items: [ self steps ];
		column: 'Status' translated
			icon: [ :each | 
			BlElement new
				geometry: BlCircle new;
				background: each resultBackgroundColor;
				size: 10 @ 10 ]
			width: 50;
		column: 'Item' translated
			text: [ :eachItem | eachItem gtDisplayText ]
]

{ #category : #accessing }
JcPipelineNode >> id [ 
	^ rawData at:'id'
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
