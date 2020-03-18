Class {
	#name : #JcWorkflowMultiBranchProject,
	#superclass : #JcModelElement,
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
		column: 'Item' translated format: [ :each | each gtDisplayText ] width: 200.
]

{ #category : #accessing }
JcWorkflowMultiBranchProject >> jobs [
	^ super modelBuilder modelFrom: (rawData at: 'jobs')
]
