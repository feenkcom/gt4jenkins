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
						geometry: BlCircle new;
						background: each resultBackgroundColor;
						size: 10 @ 10 ]
			width: 50;
		column: 'Result' translated item: [ :each | each result ] width: 70;
		column: 'Item' translated
			text: [ :each | each gtDisplayText ]
			width: 50;
		"column: 'Tests' translated format: [:each | (each tests select: [:test | test isFailed]) size asString] width: 200;"
			column: 'Duration' translated
			item: [ :each | each duration ]
			width: 200;
		column: 'Start time' translated
			item: [ :each | 
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
	^ JcJenkinsClient backgroundColorForStatus: self result
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
