Class {
	#name : #JcCoreTestSuite,
	#superclass : #Object,
	#instVars : [
		'run',
		'rawData'
	],
	#category : #'GToolkit-Jenkins-CoreAPI'
}

{ #category : #'instance creation' }
JcCoreTestSuite class >> run: aRun rawData: aDictionary [
	^ self new run: aRun rawData: aDictionary
]

{ #category : #accessing }
JcCoreTestSuite >> durationSeconds [
	^ (rawData at: 'duration' ifAbsent: [ nil ]) ifNil: [ 0 ]
]

{ #category : #accessing }
JcCoreTestSuite >> durationText [
	^ (self durationSeconds * 1000) rounded milliSeconds humanReadablePrintString
]

{ #category : #printing }
JcCoreTestSuite >> gtDisplayOn: aStream [
	aStream nextPutAll: self name
]

{ #category : #views }
JcCoreTestSuite >> gtRawDataFor: aView [
	<gtView>
	^ aView forward
		title: 'Raw data';
		priority: 90;
		object: [ rawData ];
		view: #gtItemsFor:
]

{ #category : #accessing }
JcCoreTestSuite >> name [
	^ (rawData at: 'name' ifAbsent: [ nil ]) ifNil: [ '' ]
]

{ #category : #accessing }
JcCoreTestSuite >> nodeId [
	^ rawData at: 'nodeId' ifAbsent: [ nil ]
]

{ #category : #accessing }
JcCoreTestSuite >> rawData [
	^ rawData
]

{ #category : #accessing }
JcCoreTestSuite >> run [
	^ run
]

{ #category : #initialization }
JcCoreTestSuite >> run: aRun rawData: aDictionary [
	run := aRun.
	rawData := aDictionary
]

{ #category : #accessing }
JcCoreTestSuite >> stageName [
	^ self stageNames ifEmpty: [ '' ] ifNotEmpty: [ :names | names first ]
]

{ #category : #accessing }
JcCoreTestSuite >> stageNames [
	^ (rawData at: 'enclosingBlockNames' ifAbsent: [ nil ]) ifNil: [ #() ]
]
