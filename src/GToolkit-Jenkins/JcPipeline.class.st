Class {
	#name : #JcPipeline,
	#superclass : #JcModelElement,
	#instVars : [
		'runs'
	],
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanRestImplPipeline'
}

{ #category : #accessing }
JcPipeline >> gtRunsFor: aView [
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
JcPipeline >> runs [
	runs ifNil: [runs := (super linksClientFor: 'runs') execute. runs := runs collect: [:r | r parentBranchName: (rawData at: 'fullName')]].
	^ runs
	
]
