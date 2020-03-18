Class {
	#name : #JcWorkflowRun,
	#superclass : #JcModelElement,
	#instVars : [
		'allTests'
	],
	#category : #'GToolkit-Jenkins-Generated-OrgJenkinsciPluginsWorkflowJob'
}

{ #category : #accessing }
JcWorkflowRun >> allTests [
	|client stageId allTestsResult|
	allTests ifNil: [
		client := (super fullUrlClientFor: self allTestsURL).
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
	^ allTests.
]

{ #category : #accessing }
JcWorkflowRun >> allTestsURL [
		^ (rawData at: 'url'), '/testReport/api/json'
]

{ #category : #accessing }
JcWorkflowRun >> gtDisplayOn: stream [
	stream nextPutAll: (rawData at: 'id')
]

{ #category : #accessing }
JcWorkflowRun >> result [
	^ rawData at: 'result'
]

{ #category : #accessing }
JcWorkflowRun >> resultBackgroundColor [
	^ JcJenkinsClient backgroundColorForStatus: self result
]

{ #category : #accessing }
JcWorkflowRun >> startTime [
	|st|
	st := DateAndTime fromSeconds: ((rawData at: 'timestamp') / 1000 ).
	^ st
	
]
