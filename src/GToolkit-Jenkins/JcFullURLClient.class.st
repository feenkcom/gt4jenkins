Class {
	#name : #JcFullURLClient,
	#superclass : #Object,
	#instVars : [
		'linksKey',
		'url',
		'modelBuilder'
	],
	#category : #'GToolkit-Jenkins'
}

{ #category : #accessing }
JcFullURLClient >> execute [
	|rawData model|
	rawData := self getRawData.
	model := modelBuilder modelFrom: (NeoJSONReader fromString: rawData).
	^ model.
]

{ #category : #accessing }
JcFullURLClient >> getRawData [
	|jc|
	jc := modelBuilder jenkinsClient.
	^ jc znclient get: url.
	
]

{ #category : #accessing }
JcFullURLClient >> modelBuilder [
	^ modelBuilder
]

{ #category : #accessing }
JcFullURLClient >> modelBuilder: aModelBuilder [
	modelBuilder := aModelBuilder
]

{ #category : #accessing }
JcFullURLClient >> url: aUrl [
	url := aUrl
]
