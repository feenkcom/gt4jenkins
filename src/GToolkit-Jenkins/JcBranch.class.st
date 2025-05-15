Class {
	#name : #JcBranch,
	#superclass : #JcModelElement,
	#instVars : [
		'runs'
	],
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanRestImplPipeline'
}

{ #category : #accessing }
JcBranch >> duration [
	^ (( rawData at: 'latestRun') at: 'durationInMillis') asNumber milliSeconds
]

{ #category : #'as yet unclassified' }
JcBranch >> gtBranchSummaryFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Summary';
		priority: 100;
		items: [ self summary ];
		column: 'Property' text: #key;
		column: 'Value' text: #value;
		send: #value
]

{ #category : #accessing }
JcBranch >> gtDisplayOn: stream [
	stream nextPutAll: (rawData at: 'name')
]

{ #category : #accessing }
JcBranch >> gtRunsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Runs' translated;
		priority: 50;
		items: [ self runs ];
		column: 'Status' translated 
			icon: [ :each | 
					BlElement new
						geometry: BlCircleGeometry new;
						background: each resultBackgroundColor;
						size: 10 @ 10 ]
			width: 50;
		column: 'Result' translated text: [ :each | each result ] width: 70;
		column: 'Item' translated
			text: [ :each | each gtDisplayText ]
			width: 50;
		"column: 'Tests' translated format: [:each | (each tests select: [:test | test isFailed]) size asString] width: 200;"
			column: 'Duration' translated
			text: [ :each | each duration ]
			width: 200;
		column: 'Start time' translated
			text: [ :each | 
			each startTime = 'QUEUED'
				ifTrue: [ each startTime ]
				ifFalse: [ String
						streamContents:
							[ :s | each startTime asDateAndTime asLocal printSeparateDateAndTimeOn: s ] ] ]
]

{ #category : #accessing }
JcBranch >> result [
	^ ( rawData at: 'latestRun') at: 'result'
]

{ #category : #accessing }
JcBranch >> resultBackgroundColor [
	^ JcJenkinsClient backgroundColorForResult: self result
]

{ #category : #accessing }
JcBranch >> runs [
	
	runs ifNil: [runs := (super linksClientFor: 'runs') execute. runs := runs collect: [:r | r parentBranchName: (rawData at: 'fullName')]].
	^ runs
	
]

{ #category : #accessing }
JcBranch >> startTime [
	^ (DateAndTime fromString: (( rawData at: 'latestRun') at: 'startTime')) asLocal
]

{ #category : #'as yet unclassified' }
JcBranch >> summary [
	^ {'Branch Name' -> (self rawData at: 'name').
		'Primary'
			-> (((self rawData at: 'branch') at: 'isPrimary' ifAbsent: [ false ])
					ifTrue: [ 'Yes' ]
					ifFalse: [ 'No' ]).
		'URL' -> ((self rawData at: 'branch') at: 'url' ifAbsent: [ '' ]).
		'Full Name' -> (self rawData at: 'fullName').
		'Organization' -> (self rawData at: 'organization').
		'Weather Score' -> (self rawData at: 'weatherScore') asString.
		'Latest Run ID'
			-> ((self rawData at: 'latestRun' ifAbsent: [ nil ])
					ifNotNil: [ :lr | lr at: 'id' ifAbsent: [ '' ] ]
					ifNil: [ '' ])}
]
