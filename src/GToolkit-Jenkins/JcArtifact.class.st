Class {
	#name : #JcArtifact,
	#superclass : #JcModelElement,
	#instVars : [
		'data'
	],
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanServiceEmbeddedRest'
}

{ #category : #actions }
JcArtifact >> data [
	^ data ifNil: [ data := self download ]
]

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
	<return: #Boolean>
	^ (self atPath: #(downloadable)) ifNil: [ false ]
]

{ #category : #'gt - extensions' }
JcArtifact >> gtViewFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Contents';
		text: [ self data ifNil: [ '' ] ]
]

{ #category : #'gt - extensions' }
JcArtifact >> gtViewPharoDebugLogFor: aView [
	<gtView>
	self isPharoDebugLog ifFalse: [ ^ aView empty ].

	^ aView forward
		title: 'Entries';
		priority: 10;
		object: [ GtPharoDebugLogInspector new string: self data ];
		view: #gtViewEntriesFor:
]

{ #category : #testing }
JcArtifact >> isPharoDebugLog [
	^ self name = 'PharoDebug.log'
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
