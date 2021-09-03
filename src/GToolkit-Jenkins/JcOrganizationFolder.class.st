Class {
	#name : 'JcOrganizationFolder',
	#superclass : 'JcModelElement',
	#category : 'GToolkit-Jenkins-Generated-JenkinsBranch'
}

{ #category : 'accessing' }
JcOrganizationFolder >> gtDisplayOn: stream [
	stream nextPutAll: (rawData at: 'name')
]

{ #category : 'accessing' }
JcOrganizationFolder >> gtJobsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Jobs' translated;
		priority: 50;
		items: [ self jobs];
		column: 'Item' translated text: [ :each | each gtDisplayText ] width: 200.
]

{ #category : 'accessing' }
JcOrganizationFolder >> jobs [
	^ super modelBuilder modelFrom: (rawData at: 'jobs')
]
