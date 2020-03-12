Class {
	#name : #JcPipelineNode,
	#superclass : #JcModelElement,
	#instVars : [
		'parentRun'
	],
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanRestImplPipeline'
}

{ #category : #accessing }
JcPipelineNode >> failedTests [
	|allFailed|
	allFailed := parentRun tests select: [:each | each isFailed].
	allFailed := allFailed select: [:t | t testNameParsed size = 4 and: [(t testNameParsed at: 3) trimmed asSymbol = self name asSymbol]].
	^ allFailed
]

{ #category : #accessing }
JcPipelineNode >> gtDisplayOn: stream [
	stream nextPutAll: (self name)
]

{ #category : #accessing }
JcPipelineNode >> gtFailedTestsFor: aView [
	<gtView>
	| ft|
	ft := self failedTests.
	ft isEmpty ifTrue:[ ^ aView empty].
	^ aView columnedList
		title: 'FailedTests' translated;
		priority: 60;
		items: [ self failedTests];
		column: 'Index' translated item: [ :eachItem :eachIndex | eachIndex asRopedText foreground: Color gray] width: 20;
		column: 'Status' translated do: [ :column | 
			column
				itemStencil: [ :each | BlElement new geometry: BlCircle new; background: each statusBackgroundColor; size: 10@10; margin: (BlInsets top: 5 left: 5 bottom: 5 right: 5) ];
				noResize ];
		column: 'Class' translated format: [ :eachItem | eachItem testClassName] width: 250;
		column: 'Method' translated format: [ :eachItem | eachItem testMethodName]
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
