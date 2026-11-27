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

{ #category : #views }
JcCoreArtifact class >> screenshotsElementFor: aCollectionOfImageArtifacts [
	| container |
	container := BrVerticalPane new
			hMatchParent;
			vFitContent;
			padding: (BlInsets all: 10).
	aCollectionOfImageArtifacts
		do: [ :artifact | 
			container
				addChild: (BrLabel new
						text: artifact name asRopedText;
						aptitude: BrGlamorousLabelAptitude);
				addChild: (artifact figureElement margin: (BlInsets bottom: 10)) ].
	^ container asScrollableElement
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

{ #category : #views }
JcCoreArtifact >> figureElement [
	^ (self gtFigureFor: GtPhlowView empty) asElementDo: [ :element | element ]
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

{ #category : #testing }
JcCoreArtifact >> isScripterArtifact [
	^ self scripterSegments notNil
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
JcCoreArtifact >> pathSegments [
	^ self path findTokens: '/'
]

{ #category : #accessing }
JcCoreArtifact >> platformName [
	| segments |
	segments := self pathSegments.
	^ (segments size > 2 and: [ segments first = 'artifacts' ])
		ifTrue: [ segments second ]
		ifFalse: [ '' ]
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
JcCoreArtifact >> scripterClassName [
	^ self scripterSegments ifNotNil: [ :segments | segments first ]
]

{ #category : #accessing }
JcCoreArtifact >> scripterSegments [
	| segments index |
	segments := self pathSegments asArray.
	index := segments size.
	[ index > 0 and: [ (segments at: index) ~= 'scripter' ] ]
		whileTrue: [ index := index - 1 ].
	^ (index > 0 and: [ segments size - index >= 3 ])
		ifTrue: [ segments copyFrom: index + 1 to: segments size ]
		ifFalse: [ nil ]
]

{ #category : #accessing }
JcCoreArtifact >> scripterSelector [
	^ self scripterSegments ifNotNil: [ :segments | segments second ]
]

{ #category : #accessing }
JcCoreArtifact >> url [
	^ run artifactUrlFor: rawData
]
