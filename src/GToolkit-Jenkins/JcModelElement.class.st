Class {
	#name : #JcModelElement,
	#superclass : #Object,
	#instVars : [
		'json',
		'theModelBuilder'
	],
	#category : #'GToolkit-Jenkins'
}

{ #category : #accessing }
JcModelElement >> json [
	^ json
]

{ #category : #accessing }
JcModelElement >> json: aDictionary [
	json := aDictionary
]

{ #category : #accessing }
JcModelElement >> links [
	^ nil
]

{ #category : #accessing }
JcModelElement >> linksClientFor: aLinkKey [
	|client|
	client := JcLinksClient new.
	client for: aLinkKey.
	client modelBuilder: theModelBuilder.
	client url: (((json at: '_links') at:aLinkKey) at: 'href').
	^ client.
]

{ #category : #accessing }
JcModelElement >> modelBuilder: aModelBuilder [.
	theModelBuilder := aModelBuilder
]
