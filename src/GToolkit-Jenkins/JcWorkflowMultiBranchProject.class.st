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
		column: 'Status' translated 
			icon: [ :each | BlElement new 
				geometry: BlCircle new; 
				background: each resultBackgroundColor; 
				size: 10@10 ]
			width: 50;
		column: 'Branch' translated format: [ :each | each gtDisplayText ] width: 200
]

{ #category : #accessing }
JcWorkflowMultiBranchProject >> jobs [
	jobs ifNil:[jobs:=  super modelBuilder modelFrom: (rawData at: 'jobs')].
	^ jobs
]
