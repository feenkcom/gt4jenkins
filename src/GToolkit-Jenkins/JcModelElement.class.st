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

{ #category : #accessing }
JcModelElement >> urlClientFor: aUrl [
	|client newModelBuilder jc|
	client := JcLinksClient new.
	client for: aUrl.
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
