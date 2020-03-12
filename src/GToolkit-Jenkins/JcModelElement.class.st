Class {
	#name : #JcModelElement,
	#superclass : #Object,
	#instVars : [
		'rawData',
		'theModelBuilder'
	],
	#category : #'GToolkit-Jenkins'
}

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
	client url: (((rawData at: '_links') at:aLinkKey) at: 'href').
	^ client.
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
