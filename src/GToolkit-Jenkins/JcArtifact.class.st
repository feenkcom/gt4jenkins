Class {
	#name : #JcArtifact,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanServiceEmbeddedRest'
}

{ #category : #actions }
JcArtifact >> download [
	self downloadable ifFalse: [ ^ nil ].
	self url ifNil: [ ^ nil ].

	^ JcLinksClient new
		for: #artifact;
		modelBuilder: theModelBuilder;
		url: self url;
		getRawData
]

{ #category : #accessing }
JcArtifact >> downloadable [
	^ self atPath: #(downloadable)
]

{ #category : #'gt - extensions' }
JcArtifact >> gtViewFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Contents';
		text: [ self download ifNil: [ '' ] ]
]

{ #category : #accessing }
JcArtifact >> name [
	^ self atPath: #(name)
]

{ #category : #accessing }
JcArtifact >> path [
	^ self atPath: #(path)
]

{ #category : #printing }
JcArtifact >> printOn: aStream [
	super printOn: aStream.

	aStream
		nextPut: $(;
		nextPutAll: self path asString;
		nextPut: $)
]

{ #category : #accessing }
JcArtifact >> url [
	^ self atPath: #(url)
]
