Class {
	#name : #JcCoreTestCase,
	#superclass : #Object,
	#instVars : [
		'run',
		'suiteIndex',
		'caseIndex',
		'suiteData',
		'rawData',
		'details'
	],
	#category : #'GToolkit-Jenkins-CoreAPI'
}

{ #category : #accessing }
JcCoreTestCase class >> backgroundColorForStatus: aStatus [
	aStatus = 'PASSED' ifTrue: [ ^ BrGlamorousColors successBackgroundColor ].
	aStatus = 'FIXED' ifTrue: [ ^ BrGlamorousColors successBackgroundColor ].
	(#('FAILED' 'REGRESSION') includes: aStatus)
		ifTrue: [ ^ BrGlamorousColors errorBackgroundColor ].
	aStatus = 'SKIPPED' ifTrue: [ ^ BrGlamorousColors failureBackgroundColor ].
	^ BrGlamorousColors neutralBackgroundColor
]

{ #category : #accessing }
JcCoreTestCase class >> problematicStatuses [
	^ #('FAILED' 'REGRESSION' 'SKIPPED')
]

{ #category : #'instance creation' }
JcCoreTestCase class >> run: aRun suiteIndex: aSuiteIndex caseIndex: aCaseIndex suiteData: aSuite rawData: aDictionary [
	^ self new
		run: aRun
		suiteIndex: aSuiteIndex
		caseIndex: aCaseIndex
		suiteData: aSuite
		rawData: aDictionary
]

{ #category : #accessing }
JcCoreTestCase >> className [
	^ rawData at: 'className' ifAbsent: [ '' ]
]

{ #category : #accessing }
JcCoreTestCase >> details [
	^ details
		ifNil: [ details := run caseDetailsAtSuite: suiteIndex case: caseIndex ]
]

{ #category : #accessing }
JcCoreTestCase >> errorDetails [
	^ (self details at: 'errorDetails' ifAbsent: [ nil ]) ifNil: [ '' ]
]

{ #category : #accessing }
JcCoreTestCase >> errorStackTrace [
	^ (self details at: 'errorStackTrace' ifAbsent: [ nil ]) ifNil: [ '' ]
]

{ #category : #views }
JcCoreTestCase >> gtArtifactsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Scripter artifacts';
		question: 'Which scripter files did this build archive for this test?';
		priority: 5;
		items: [ self scripterArtifacts ];
		column: 'File' text: [ :artifact | artifact name ];
		column: 'Path' text: [ :artifact | artifact path ]
]

{ #category : #printing }
JcCoreTestCase >> gtDisplayOn: aStream [
	aStream
		nextPutAll: self shortClassName;
		nextPutAll: '>>#';
		nextPutAll: self name
]

{ #category : #views }
JcCoreTestCase >> gtErrorDetailsFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Error details';
		question: 'Why did this test fail or get skipped?';
		priority: 4;
		aptitude: [ BrGlamorousRegularEditorAptitude ];
		text: [ | aText |
			aText := 'Details' asRopedText bold.
			aText append: String cr asRopedText.
			aText
				append: (self isSkipped ifTrue: [ self skippedMessage ] ifFalse: [ self errorDetails ])
						asRopedText.
			aText append: String cr asRopedText.
			aText append: String cr asRopedText.
			aText append: 'Stack' asRopedText bold.
			aText append: String cr asRopedText.
			aText append: self errorStackTrace asRopedText ]
]

{ #category : #views }
JcCoreTestCase >> gtRawDataFor: aView [
	<gtView>
	^ aView forward
		title: 'Raw data';
		question: 'Which test fields did Jenkins return?';
		priority: 100;
		object: [ self rawData ];
		view: #gtTreeFor:context:
]

{ #category : #views }
JcCoreTestCase >> gtScreenshotsFor: aView [
	<gtView>
	^ aView explicit
		title: 'Screenshots';
		question: 'What did the scripter capture for this test?';
		priority: 3;
		stencil: [ JcCoreArtifact
				screenshotsElementFor: (self scripterArtifacts select: [ :each | each isImage ]) ]
]

{ #category : #views }
JcCoreTestCase >> gtTestFor: aView [
	<gtView>
	self testMethod ifNotNil: [ :aMethod | ^ aMethod gtSourceFor: aView ].
	^ aView textEditor
		title: 'Not found';
		glamorousRegularFontAndSize;
		text: [ String
				streamContents: [ :aStream | 
					aStream
						nextPutAll: 'Source code not found:';
						cr;
						nextPutAll: ' - class: ';
						print: self shortClassName;
						cr;
						nextPutAll: ' - method: ';
						print: self name;
						cr ] ]
]

{ #category : #testing }
JcCoreTestCase >> isFailed [
	^ #('FAILED' 'REGRESSION') includes: self status
]

{ #category : #testing }
JcCoreTestCase >> isSkipped [
	^ self status = 'SKIPPED'
]

{ #category : #accessing }
JcCoreTestCase >> name [
	^ rawData at: 'name' ifAbsent: [ '' ]
]

{ #category : #accessing }
JcCoreTestCase >> rawData [
	^ rawData
]

{ #category : #views }
JcCoreTestCase >> resultBackgroundColor [
	^ self class backgroundColorForStatus: self status
]

{ #category : #accessing }
JcCoreTestCase >> run [
	^ run
]

{ #category : #initialization }
JcCoreTestCase >> run: aRun suiteIndex: aSuiteIndex caseIndex: aCaseIndex suiteData: aSuite rawData: aDictionary [
	run := aRun.
	suiteIndex := aSuiteIndex.
	caseIndex := aCaseIndex.
	suiteData := aSuite.
	rawData := aDictionary.
	details := nil
]

{ #category : #accessing }
JcCoreTestCase >> scripterArtifacts [
	^ run scripterArtifactsForTestCase: self
]

{ #category : #accessing }
JcCoreTestCase >> shortClassName [
	^ (self className findTokens: '.')
		ifEmpty: [ '' ]
		ifNotEmpty: [ :parts | parts last ]
]

{ #category : #accessing }
JcCoreTestCase >> skippedMessage [
	^ (self details at: 'skippedMessage' ifAbsent: [ nil ]) ifNil: [ '' ]
]

{ #category : #accessing }
JcCoreTestCase >> stageNames [
	^ (suiteData at: 'enclosingBlockNames' ifAbsent: [ nil ]) ifNil: [ #() ]
]

{ #category : #accessing }
JcCoreTestCase >> stageNodeId [
	^ suiteData at: 'nodeId' ifAbsent: [ nil ]
]

{ #category : #accessing }
JcCoreTestCase >> status [
	^ rawData at: 'status' ifAbsent: [ '' ]
]

{ #category : #views }
JcCoreTestCase >> statusIcon [
	^ BlElement new
		geometry: BlCircleGeometry new;
		background: self resultBackgroundColor;
		size: 10 @ 10
]

{ #category : #accessing }
JcCoreTestCase >> suiteName [
	^ suiteData at: 'name' ifAbsent: [ '' ]
]

{ #category : #accessing }
JcCoreTestCase >> testMethod [
	| aClass aSelector |
	aClass := self shortClassName asClassIfAbsent: [ ^ nil ].
	aSelector := self name asSymbol.
	^ (aClass instanceSide lookupSelector: aSelector)
		ifNil: [ aClass classSide lookupSelector: aSelector ]
]
