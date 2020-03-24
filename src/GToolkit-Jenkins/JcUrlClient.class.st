Class {
	#name : #JcUrlClient,
	#superclass : #Object,
	#instVars : [
		'linksKey',
		'url',
		'modelBuilder'
	],
	#category : #'GToolkit-Jenkins'
}

{ #category : #accessing }
JcUrlClient >> execute [
	|rawData model|
	rawData:=self getRawData.
	[model := modelBuilder modelFrom: (NeoJSONReader fromString: rawData).] on: NeoJSONParseError do: [ ^ nil].
	^ model.
]

{ #category : #accessing }
JcUrlClient >> getRawData [
	|model jc|
	jc := modelBuilder jenkinsClient.
	^ jc znclient get: ('' join:{jc url . url}).
	
]

{ #category : #accessing }
JcUrlClient >> modelBuilder [
	^ modelBuilder
]

{ #category : #accessing }
JcUrlClient >> modelBuilder: aModelBuilder [
	modelBuilder := aModelBuilder
]

{ #category : #accessing }
JcUrlClient >> url: aUrl [
	url := aUrl
]
