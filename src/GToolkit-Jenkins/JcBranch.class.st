Class {
	#name : #JcBranch,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanRestImplPipeline'
}

{ #category : #accessing }
JcBranch >> duration [
	^ (( json at: 'latestRun') at: 'durationInMillis') asNumber milliSeconds
]

{ #category : #accessing }
JcBranch >> gtDisplayOn: stream [
	stream nextPutAll: (json at: 'name')
]

{ #category : #accessing }
JcBranch >> gtRunsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Runs' translated;
		priority: 50;
		items: [ self runs];
		column: 'Status' translated do: [ :column | 
			column
				itemStencil: [ :each | BlElement new geometry: BlCircle new; background: each resultBackgroundColor; size: 10@10; margin: (BlInsets top: 5 left: 5 bottom: 5 right: 5) ];
				noResize ];
		column: 'Result' translated format: [ :each | each result ] width: 70;
		column: 'Item' translated format: [ :each | each gtDisplayText ] width: 50;
		"column: 'Tests' translated format: [:each | (each tests select: [:test | test isFailed]) size asString] width: 200;"
		column: 'Duration' translated format: [ :each | (each duration roundTo: 1 second) humanReadablePrintString ] width: 200;
		column: 'Start time' translated format: [ :each | String streamContents: [:s | each startTime printSeparateDateAndTimeOn: s]]
]

{ #category : #accessing }
JcBranch >> result [
	^ ( json at: 'latestRun') at: 'result'
]

{ #category : #accessing }
JcBranch >> resultBackgroundColor [
	^ JcJenkinsClient backgroundColorForStatus: self result
]

{ #category : #accessing }
JcBranch >> runs [
	^ (super linksClientFor: 'runs') execute
]

{ #category : #accessing }
JcBranch >> startTime [
	^ DateAndTime fromString: (( json at: 'latestRun') at: 'startTime')
]
