Class {
	#name : #JcArtifact,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanServiceEmbeddedRest'
}

{ #category : #actions }
JcArtifact >> download [
	"Answer the receiver's contents"
	| jcClient znUrl |

	self downloadable ifFalse: [ ^ nil ].
	self url ifNil: [ ^ nil ].

	jcClient := theModelBuilder jenkinsClient.
	"Using basic authentication appears to be more reliable than the bearer / cookie"
	znUrl := (jcClient getRootOfUrl, self url) asZnUrl.
	znUrl
		username: jcClient username;
		password: jcClient password.
	^ ZnClient new
		url: znUrl;
		get.
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
