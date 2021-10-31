Class {
	#name : #JcOrganization,
	#superclass : #JcModelElement,
	#category : 'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanServiceEmbeddedRest'
}

{ #category : #accessing }
JcOrganization >> gtDisplayOn: stream [
	stream nextPutAll: (rawData at:'name')
]

{ #category : #accessing }
JcOrganization >> gtPipelinesFor: aView [
	<gtView>
	^ aView columnedTree
		title: 'Jobs' translated;
		priority: 10;
		items: [ self pipelines ];
		children: [:each | (each class canUnderstand: #pipelines) ifTrue: [ each pipelines ] ifFalse: [{}]];
		column: 'Name' translated text: [ :p | p rawData at: 'name' ]
]

{ #category : #accessing }
JcOrganization >> pipelines [
	^ (super linksClientFor: 'pipelines') execute
]
