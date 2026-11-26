"
{{gtClass:JcCoreRun}} represents a Jenkins build. It retains the summary response and lazily fetches build details through {{gtClass:JcCoreClient}}.
"
Class {
	#name : #JcCoreRun,
	#superclass : #Object,
	#instVars : [
		'client',
		'jobNames',
		'rawData',
		'details'
	],
	#category : #'GToolkit-Jenkins-CoreAPI'
}

{ #category : #'instance creation' }
JcCoreRun class >> client: aClient jobNames: names rawData: aDictionary [
	^ self new
		client: aClient
		jobNames: names
		rawData: aDictionary
]

{ #category : #accessing }
JcCoreRun >> building [
	^ self detailAt: 'building'
]

{ #category : #initialization }
JcCoreRun >> client: aClient jobNames: names rawData: aDictionary [
	client := aClient.
	jobNames := names asArray.
	rawData := aDictionary.
	^ self
]

{ #category : #details }
JcCoreRun >> detailAt: aKey [
	^ self details at: aKey ifAbsent: [ nil ]
]

{ #category : #details }
JcCoreRun >> details [
	| path |
	details
		ifNil: [ path := client jobPathSegmentsForNames: jobNames.
			path add: self number asString.
			details := client
					getJsonAtPathSegments: path
					tree: 'number,result,timestamp,duration,url,building' ].
	^ details
]

{ #category : #accessing }
JcCoreRun >> duration [
	^ self detailAt: 'duration'
]

{ #category : #'gt - views' }
JcCoreRun >> gtDetailsFor: aView [
	<gtView>
	^ aView forward
		title: 'Details';
		question: 'What is the current state and timing of this Jenkins build?';
		priority: 20;
		object: [ self details ];
		view: #gtTreeFor:context:
]

{ #category : #printing }
JcCoreRun >> gtDisplayOn: aStream [
	aStream
		nextPut: $#;
		nextPutAll: self number asString
]

{ #category : #'gt - views' }
JcCoreRun >> gtRawDataFor: aView [
	<gtView>
	^ aView forward
		title: 'Raw data';
		question: 'What summary JSON data created this Jenkins build?';
		priority: 90;
		object: [ self rawData ];
		view: #gtTreeFor:context:
]

{ #category : #accessing }
JcCoreRun >> number [
	^ rawData at: 'number'
]

{ #category : #accessing }
JcCoreRun >> rawData [
	^ rawData
]

{ #category : #accessing }
JcCoreRun >> result [
	^ self detailAt: 'result'
]

{ #category : #accessing }
JcCoreRun >> timestamp [
	^ self detailAt: 'timestamp'
]

{ #category : #accessing }
JcCoreRun >> url [
	^ rawData at: 'url' ifAbsent: [ self detailAt: 'url' ]
]
