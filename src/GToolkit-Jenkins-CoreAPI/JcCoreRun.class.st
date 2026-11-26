"
{{gtClass:JcCoreRun}} represents a Jenkins build from {{gtClass:JcCoreClient}}. It retains the build summary and lazily loads details and archived artifacts from the Jenkins core Remote API. The optional Stages view reads the Pipeline Stage View plugin endpoint, and the Problematic tests view reads the JUnit plugin report when present. Use {{gtSymbol:refreshStages}} and {{gtSymbol:refreshProblematicTests}} to update those cached views.
"
Class {
	#name : #JcCoreRun,
	#superclass : #Object,
	#instVars : [
		'client',
		'jobNames',
		'rawData',
		'details',
		'artifacts',
		'stages',
		'problematicTests'
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

{ #category : #artifacts }
JcCoreRun >> artifactUrlFor: anArtifact [
	| path url |
	path := anArtifact at: 'relativePath' ifAbsent: [ ^ nil ].
	url := client baseUrl copy.
	(client jobPathSegmentsForNames: jobNames)
		do: [ :segment | url addPathSegment: segment ].
	url addPathSegment: self number asString.
	url addPathSegment: 'artifact'.
	(path findTokens: '/') do: [ :segment | url addPathSegment: segment ].
	^ url asString
]

{ #category : #artifacts }
JcCoreRun >> artifacts [
	| path response |
	artifacts
		ifNil: [ path := client jobPathSegmentsForNames: jobNames.
			path add: self number asString.
			response := client
					getJsonAtPathSegments: path
					tree: 'artifacts[fileName,relativePath]'.
			artifacts := response at: 'artifacts' ifAbsent: [ #() ] ].
	^ artifacts
]

{ #category : #accessing }
JcCoreRun >> building [
	^ rawData at: 'building' ifAbsent: [ self detailAt: 'building' ]
]

{ #category : #initialization }
JcCoreRun >> client: aClient jobNames: names rawData: aDictionary [
	client := aClient.
	jobNames := names asArray.
	rawData := aDictionary.
	details := nil.
	artifacts := nil.
	stages := nil.
	problematicTests := nil.
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
	^ rawData at: 'duration' ifAbsent: [ self detailAt: 'duration' ]
]

{ #category : #accessing }
JcCoreRun >> durationText [
	| elapsed milliseconds |
	self building = true
		ifTrue: [ elapsed := self startTime ifNil: [ ^ 'RUNNING' ].
			^ (DateAndTime now - elapsed) humanReadablePrintString ].
	milliseconds := self duration.
	^ milliseconds
		ifNil: [ '' ]
		ifNotNil: [ milliseconds milliSeconds humanReadablePrintString ]
]

{ #category : #'gt - views' }
JcCoreRun >> gtArtifactsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Artifacts';
		question: 'Which files did this Jenkins build archive?';
		priority: 40;
		items: [ self artifacts ];
		column: 'Path'
			text: [ :artifact | artifact at: 'relativePath' ifAbsent: [ '' ] ];
		column: 'File' text: [ :artifact | artifact at: 'fileName' ifAbsent: [ '' ] ];
		column: 'Download URL'
			text: [ :artifact | (self artifactUrlFor: artifact) ifNil: [ '' ] ]
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

{ #category : #views }
JcCoreRun >> gtProblematicTestsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Problematic tests';
		question: 'Which JUnit tests failed or were skipped in this build?';
		priority: 50;
		items: [ self problematicTests ];
		column: 'Status' text: [ :case | case at: 'status' ifAbsent: [ '' ] ];
		column: 'Class' text: [ :case | case at: 'className' ifAbsent: [ '' ] ];
		column: 'Test' text: [ :case | case at: 'name' ifAbsent: [ '' ] ];
		actionButtonIcon: BrGlamorousVectorIcons refresh
			tooltip: 'Refresh tests'
			action: [ :button :tab | 
				self refreshProblematicTests.
				tab viewContentElement phlow update ]
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

{ #category : #views }
JcCoreRun >> gtStagesFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Stages';
		question: 'Which stages did this Jenkins Pipeline build run?';
		priority: 30;
		items: [ self stages ];
		column: 'Status' text: [ :stage | stage at: 'status' ifAbsent: [ '' ] ];
		column: 'Stage' text: [ :stage | stage at: 'name' ifAbsent: [ '' ] ];
		column: 'Duration'
			text: [ :stage | 
				| millis |
				millis := stage at: 'durationMillis' ifAbsent: [ nil ].
				millis
					ifNil: [ '' ]
					ifNotNil: [ (millis max: 0) milliSeconds humanReadablePrintString ] ];
		actionButtonIcon: BrGlamorousVectorIcons refresh
			tooltip: 'Refresh stages'
			action: [ :button :tab | 
				self refreshStages.
				tab viewContentElement phlow update ]
]

{ #category : #accessing }
JcCoreRun >> number [
	^ rawData at: 'number'
]

{ #category : #accessing }
JcCoreRun >> problematicTests [
	^ problematicTests ifNil: [ self refreshProblematicTests ]
]

{ #category : #accessing }
JcCoreRun >> rawData [
	^ rawData
]

{ #category : #accessing }
JcCoreRun >> refreshProblematicTests [
	| path response cases newTests |
	self building = true
		ifTrue: [ problematicTests := #().
			^ problematicTests ].
	path := client jobPathSegmentsForNames: jobNames.
	path add: self number asString.
	path add: 'testReport'.
	path add: 'api'.
	path add: 'json'.
	response := [ client
			getJsonAtPathSegments: path
			query: (Dictionary new
					at: 'tree' put: 'suites[cases[className,name,status]]';
					yourself) ]
			on: ZnHttpUnsuccessful
			do: [ :error | error response code = 404 ifTrue: [ Dictionary new ] ifFalse: [ error pass ] ].
	cases := (response at: 'suites' ifAbsent: [ #() ])
			flatCollect: [ :suite | suite at: 'cases' ifAbsent: [ #() ] ].
	newTests := cases
			select: [ :each | 
				#('FAILED' 'REGRESSION' 'SKIPPED')
					includes: (each at: 'status' ifAbsent: [ '' ]) ].
	problematicTests := newTests.
	^ problematicTests
]

{ #category : #accessing }
JcCoreRun >> refreshStages [
	| path response newStages |
	path := client jobPathSegmentsForNames: jobNames.
	path add: self number asString.
	path add: 'wfapi'.
	path add: 'describe'.
	response := [ client getJsonAtPathSegments: path ]
			on: ZnHttpUnsuccessful
			do: [ :error | error response code = 404 ifTrue: [ Dictionary new ] ifFalse: [ error pass ] ].
	newStages := response at: 'stages' ifAbsent: [ #() ].
	stages := newStages.
	^ stages
]

{ #category : #accessing }
JcCoreRun >> result [
	^ rawData at: 'result' ifAbsent: [ self detailAt: 'result' ]
]

{ #category : #accessing }
JcCoreRun >> resultBackgroundColor [
	self building = true ifTrue: [ ^ BrGlamorousColors neutralBackgroundColor ].
	self result = 'SUCCESS' ifTrue: [ ^ BrGlamorousColors successBackgroundColor ].
	self result = 'FAILURE' ifTrue: [ ^ BrGlamorousColors errorBackgroundColor ].
	self result = 'UNSTABLE' ifTrue: [ ^ BrGlamorousColors failureBackgroundColor ].
	^ BrGlamorousColors lightBorderColor
]

{ #category : #accessing }
JcCoreRun >> resultText [
	self building = true ifTrue: [ ^ 'RUNNING' ].
	^ self result ifNil: [ 'UNKNOWN' ]
]

{ #category : #accessing }
JcCoreRun >> stages [
	^ stages ifNil: [ self refreshStages ]
]

{ #category : #accessing }
JcCoreRun >> startTime [
	| milliseconds |
	milliseconds := self timestamp.
	^ milliseconds ifNotNil: [ DateAndTime fromSeconds: milliseconds / 1000 ]
]

{ #category : #accessing }
JcCoreRun >> startTimeText [
	| time |
	time := self startTime.
	^ time
		ifNil: [ '' ]
		ifNotNil: [ String
				streamContents: [ :stream | time asLocal printSeparateDateAndTimeOn: stream ] ]
]

{ #category : #'gt - views' }
JcCoreRun >> statusIcon [
	^ BlElement new
		geometry: BlCircleGeometry new;
		background: self resultBackgroundColor;
		size: 10 @ 10
]

{ #category : #accessing }
JcCoreRun >> timestamp [
	^ rawData at: 'timestamp' ifAbsent: [ self detailAt: 'timestamp' ]
]

{ #category : #accessing }
JcCoreRun >> url [
	^ rawData at: 'url' ifAbsent: [ self detailAt: 'url' ]
]
