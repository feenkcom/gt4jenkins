Class {
	#name : #JcWorkflowJob,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins-Generated-OrgJenkinsciPluginsWorkflowJob'
}

{ #category : #accessing }
JcWorkflowJob >> builds [
	^ super modelBuilder modelFrom: (rawData at: 'builds')
]

{ #category : #accessing }
JcWorkflowJob >> gtBuildsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Builds' translated;
		priority: 50;
		items: [ self builds];
		column: 'Item' translated format: [ :each | each gtDisplayText ] width: 200.
]

{ #category : #accessing }
JcWorkflowJob >> gtDisplayOn: stream [
	stream nextPutAll: (rawData at: 'name')
]
