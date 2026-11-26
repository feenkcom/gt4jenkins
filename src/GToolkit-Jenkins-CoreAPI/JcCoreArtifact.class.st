"
{{gtClass:JcCoreArtifact}} represents an archived file of a {{gtClass:JcCoreRun}}. It retains the Jenkins core artifact summary and lazily downloads the file when its contents are inspected.
"
Class {
	#name : #JcCoreArtifact,
	#superclass : #Object,
	#instVars : [
		'run',
		'rawData',
		'data',
		'dataLoaded'
	],
	#category : #'GToolkit-Jenkins-CoreAPI'
}

{ #category : #'instance creation' }
JcCoreArtifact class >> run: aRun rawData: aDictionary [
	^ self new run: aRun rawData: aDictionary
]

{ #category : #accessing }
JcCoreArtifact >> data [
	dataLoaded = true ifTrue: [ ^ data ].
	data := self download.
	dataLoaded := true.
	^ data
]

{ #category : #accessing }
JcCoreArtifact >> download [
	self downloadable ifFalse: [ ^ nil ].
	^ run artifactContentsFor: rawData
]

{ #category : #testing }
JcCoreArtifact >> downloadable [
	^ self path isEmpty not
]

{ #category : #printing }
JcCoreArtifact >> gtDisplayOn: aStream [
	aStream nextPutAll: self path
]

{ #category : #views }
JcCoreArtifact >> gtFigureFor: aView [
	<gtView>
	self isImage ifFalse: [ ^ aView empty ].
	^ aView forward
		title: 'Figure';
		question: 'What does this archived image show?';
		priority: 10;
		object: [ self data ];
		view: #gtFigureFor:
]

{ #category : #views }
JcCoreArtifact >> gtViewFor: aView [
	<gtView>
	self isImage ifTrue: [ ^ aView empty ].
	^ aView textEditor
		title: 'Contents';
		question: 'What does this archived file contain?';
		priority: 10;
		text: [ self data ifNil: [ '' ] ]
]

{ #category : #views }
JcCoreArtifact >> gtViewPharoDebugLogFor: aView [
	<gtView>
	self isPharoDebugLog ifFalse: [ ^ aView empty ].
	^ aView forward
		title: 'Entries';
		question: 'Which entries are in this Pharo debug log?';
		priority: 20;
		object: [ GtPharoDebugLogInspector new string: (self data ifNil: [ '' ]) ];
		view: #gtViewEntriesFor:
]

{ #category : #testing }
JcCoreArtifact >> isImage [
	^ ImageReadWriter allTypicalFileExtensions
		includes: ($. split: self name) last asLowercase
]

{ #category : #testing }
JcCoreArtifact >> isPharoDebugLog [
	^ self name = 'PharoDebug.log'
]

{ #category : #accessing }
JcCoreArtifact >> name [
	^ rawData at: 'fileName' ifAbsent: [ '' ]
]

{ #category : #accessing }
JcCoreArtifact >> path [
	^ rawData at: 'relativePath' ifAbsent: [ '' ]
]

{ #category : #accessing }
JcCoreArtifact >> rawData [
	^ rawData
]

{ #category : #initialization }
JcCoreArtifact >> run: aRun rawData: aDictionary [
	run := aRun.
	rawData := aDictionary.
	data := nil.
	dataLoaded := false.
	^ self
]

{ #category : #accessing }
JcCoreArtifact >> url [
	^ run artifactUrlFor: rawData
]
