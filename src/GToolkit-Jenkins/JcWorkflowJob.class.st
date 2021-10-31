Class {
	#name : #JcWorkflowJob,
	#superclass : #JcModelElement,
	#instVars : [
		'builds'
	],
	#category : #'GToolkit-Jenkins-Generated-OrgJenkinsciPluginsWorkflowJob'
}

{ #category : #accessing }
JcWorkflowJob >> builds [
	builds ifNil: [ 
	rawData at: 'builds' ifPresent: [:data | 
		builds := super modelBuilder modelFrom: data ] 
		ifAbsent: [builds := OrderedCollection new]].
	
	^ builds
]

{ #category : #accessing }
JcWorkflowJob >> gtBuildsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Builds' translated;
		priority: 50;
		items: [ self builds ];
		column: 'Status' translated
			icon: [ :each | 
			BlElement new
				geometry: BlCircleGeometry new;
				background: each resultBackgroundColor;
				size: 10 @ 10 ]
			width: 50;
		column: 'Item' translated
			text: [ :each | each gtDisplayText ]
			width: 200
]

{ #category : #accessing }
JcWorkflowJob >> gtDisplayOn: stream [
	stream nextPutAll: (rawData at: 'name')
]

{ #category : #accessing }
JcWorkflowJob >> resultBackgroundColor [
	self builds size > 0 ifTrue:[^ self builds last resultBackgroundColor ].
	^ Color gray
	
]

{ #category : #accessing }
JcWorkflowJob >> startTime [
	^ self builds last startTime
]
