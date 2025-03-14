Class {
	#name : #JcModelElement,
	#superclass : #Object,
	#instVars : [
		'rawData',
		'theModelBuilder'
	],
	#category : #'GToolkit-Jenkins'
}

{ #category : #'accessing - raw data' }
JcModelElement >> atPath: keyCollection [
	"Use each key in keyCollection recursively, stop when nil is encountered"

	| value |
	rawData ifNil: [ ^ nil ].
	
	value := rawData.
	keyCollection do: [ :each |
		value := value at: each ifAbsent: [ ^ nil ].
		value ifNil: [ ^ nil ] ].
	^ value
]

{ #category : #'accessing - raw data' }
JcModelElement >> atPath: keyCollection ifPresent: presentBlock ifAbsent: absentBlock [
	"Use each key in keyCollection recursively, stop when nil is encountered"

	| value |
	rawData ifNil: [ ^ absentBlock value ].
	
	value := rawData.
	keyCollection do: [ :each |
		value := value at: each ifAbsent: [ ^ absentBlock value ].
		value ifNil: [ ^ absentBlock value ] ].
	^ presentBlock value: value
]

{ #category : #accessing }
JcModelElement >> fullUrlClientFor: aUrl [
	|client newModelBuilder jc|
	client := JcFullURLClient new.
	
	jc := JcJenkinsClient new.
	jc username: (theModelBuilder jenkinsClient username)
	    token: (theModelBuilder jenkinsClient password)
		url: (theModelBuilder jenkinsClient url).
	newModelBuilder := JcModelBuilder new.
	(newModelBuilder jenkinsClient: jc).
	
	client modelBuilder: newModelBuilder.
	client url: aUrl.
	^ client.
]

{ #category : #'gt - extensions' }
JcModelElement >> gtLinksFor: aView [
	<gtView>
	rawData ifNil: [ ^ aView empty ].

	^ aView list
		title: 'Links';
		priority: 90;
		items: [ self links keys sorted ];
		send: [ :item | (self linksClientFor: item) execute ]
]

{ #category : #'gt - extensions' }
JcModelElement >> gtRawDataFor: aView [
	<gtView>
	rawData ifNil: [ ^ aView empty ].

	^ aView forward
		title: 'Raw data';
		priority: 90;
		object: [ self rawData ];
		view: #gtTreeFor:context:
]

{ #category : #accessing }
JcModelElement >> gtUrlStringFor: aView [
	<gtView>
	^ aView explicit
		title: 'URL';
		priority: 90;
		stencil: [
			BrEditorElement new
				margin: (BlInsets all: 10);
				constraintsDo: [ :c | 
					c vertical matchParent. 
					c horizontal matchParent ];
				editor: (BrTextEditorModel new
					text: ( self selfUrl asRopedText
						glamorousRegularFontAndSize) ) ]
]

{ #category : #accessing }
JcModelElement >> links [
	^ rawData at:'_links' ifAbsent: [Dictionary new]
]

{ #category : #accessing }
JcModelElement >> linksClientFor: aLinkKey [
	|client|
	client := JcLinksClient new.
	client for: aLinkKey.
	client modelBuilder: theModelBuilder.
	client url: (((rawData at: '_links') at:aLinkKey) at: 'href').
	^ client.
]

{ #category : #accessing }
JcModelElement >> modelBuilder [
	^ theModelBuilder
]

{ #category : #accessing }
JcModelElement >> modelBuilder: aModelBuilder [.
	theModelBuilder := aModelBuilder
]

{ #category : #accessing }
JcModelElement >> rawData [
	^ rawData
]

{ #category : #accessing }
JcModelElement >> rawData: aDictionary [
	rawData := aDictionary
]

{ #category : #accessing }
JcModelElement >> selfUrl [
	| relativeUrl |
	relativeUrl := self links at: 'self' ifPresent: [:link | link at: 'href' ifAbsent: [''] ] ifAbsent: [''].
	^ self modelBuilder jenkinsClient getRootOfUrl, relativeUrl
]

{ #category : #accessing }
JcModelElement >> urlClientFor: aUrl [
	|client newModelBuilder jc|
	client := JcUrlClient new.
	
	jc := JcJenkinsClient new.
	jc username: (theModelBuilder jenkinsClient username)
	    token: (theModelBuilder jenkinsClient password)
		url: (theModelBuilder jenkinsClient url).
	newModelBuilder := JcModelBuilder new.
	(newModelBuilder jenkinsClient: jc).
	jc setupJwtToken.
	client modelBuilder: newModelBuilder.
	client url: aUrl.
	^ client.
]
