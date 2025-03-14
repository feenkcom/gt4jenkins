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
	|rawData model|
	rawData:=self getRawData.
	model := modelBuilder modelFrom: (NeoJSONReader fromString: rawData).
	^ model.
]

{ #category : #accessing }
JcLinksClient >> for: aLinksKey [
	linksKey := aLinksKey
]

{ #category : #accessing }
JcLinksClient >> getRawData [
	|jc rootUrl|
	jc := modelBuilder jenkinsClient.
	rootUrl := jc url asUrl scheme asString, '://', jc url asUrl host.
	^ jc znclient get: ('' join:{rootUrl . url}).
	
]

{ #category : #accessing }
JcLinksClient >> modelBuilder [
	^ modelBuilder
]

{ #category : #accessing }
JcLinksClient >> modelBuilder: aModelBuilder [
	modelBuilder := aModelBuilder
]

{ #category : #accessing }
JcLinksClient >> url: aUrl [
	url := aUrl
]
