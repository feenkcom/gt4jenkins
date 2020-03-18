Class {
	#name : #JcWorkflowMultiBranchProject,
	#superclass : #JcModelElement,
	#instVars : [
		'jobs'
	],
	#category : #'GToolkit-Jenkins-Generated-OrgJenkinsciPluginsWorkflowMultibranch'
}

{ #category : #accessing }
JcWorkflowMultiBranchProject >> gtDisplayOn: stream [
	stream nextPutAll: (rawData at: 'name')
]

{ #category : #accessing }
JcWorkflowMultiBranchProject >> gtJobsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Jobs' translated;
		priority: 50;
		items: [ self jobs];
		column: 'Status' translated do: [ :column | 
			column
				itemStencil: [ :each | BlElement new geometry: BlCircle new; background: each resultBackgroundColor; size: 10@10; margin: (BlInsets top: 5 left: 5 bottom: 5 right: 5) ];
				noResize ];
		column: 'Branch' translated format: [ :each | each gtDisplayText ] width: 200
]

{ #category : #accessing }
JcWorkflowMultiBranchProject >> jobs [
	jobs ifNil:[jobs:=  super modelBuilder modelFrom: (rawData at: 'jobs')].
	^ jobs
]
