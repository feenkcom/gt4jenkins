Class {
	#name : #JcHudson,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins-Generated-HudsonModel'
}

{ #category : #accessing }
JcHudson >> gtJobsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Jobs' translated;
		priority: 50;
		items: [ self jobs];
		column: 'Item' translated format: [ :each | each gtDisplayText ] width: 200.
]

{ #category : #accessing }
JcHudson >> jobs [
	^ super modelBuilder modelFrom: (rawData at: 'jobs')
]
