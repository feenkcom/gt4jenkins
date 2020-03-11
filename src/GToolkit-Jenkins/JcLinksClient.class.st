Class {
	#name : #JcLinksClient,
	#superclass : #Object,
	#instVars : [
		'linksKey',
		'url',
		'modelBuilder'
	],
	#category : #'GToolkit-Jenkins'
}

{ #category : #accessing }
JcLinksClient >> execute [
	|json model jc|
	jc := modelBuilder jenkinsClient.
	json := jc znclient get: ('' join:{jc url . url}).
	model := modelBuilder modelFrom: (NeoJSONReader fromString: json).
	^ model.
]

{ #category : #accessing }
JcLinksClient >> for: aLinksKey [
	linksKey := aLinksKey
]

{ #category : #accessing }
JcLinksClient >> modelBuilder: aModelBuilder [
	modelBuilder := aModelBuilder
]

{ #category : #accessing }
JcLinksClient >> url: aUrl [
	url := aUrl
]
