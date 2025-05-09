Class {
	#name : #JcOrganization,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanServiceEmbeddedRest'
}

{ #category : #'as yet unclassified' }
JcOrganization >> allPipelines [
	^ self pipelines
		flatCollect: [ :each | 
			(each class canUnderstand: #pipelines)
				ifTrue: [ each pipelines ]
				ifFalse: [ {each} ] ]
]

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

{ #category : #'as yet unclassified' }
JcOrganization >> gtSearchJobsFor: aSearch [
	<gtSearch>
	^ aSearch list
		title: 'Jobe';
		priority: 30;
		items: [ self allPipelines ];
		itemsLimit: Float infinity;
		itemName: [ :p | p rawData at: 'name' ];
		filterBySubstring
]

{ #category : #accessing }
JcOrganization >> pipelines [
	^ (super linksClientFor: 'pipelines') execute
]
