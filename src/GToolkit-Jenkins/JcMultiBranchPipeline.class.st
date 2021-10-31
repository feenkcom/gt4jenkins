Class {
	#name : #JcMultiBranchPipeline,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanRestImplPipeline'
}

{ #category : #accessing }
JcMultiBranchPipeline >> branches [
	^ (super linksClientFor: 'branches') execute
]

{ #category : #accessing }
JcMultiBranchPipeline >> gtBranchesFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Branches' translated;
		priority: 50;
		items: [ self branches ];
		column: 'Status' translated
			icon: [ :each | 
					BlElement new
						geometry: BlCircleGeometry new;
						background: each resultBackgroundColor;
						size: 10 @ 10;
						margin:
							(BlInsets
								top: 5
								left: 5
								bottom: 5
								right: 5) ]
			width: 50;
		column: 'Branch' translated
			text: [ :each | each gtDisplayText ]
			width: 110;
		column: 'Last duration' translated
			text: [ :each | (each duration roundTo: 1 second) humanReadablePrintString ]
			width: 150;
		column: 'Last run start time' translated
			text: [ :each | 
			String
				streamContents:
					[ :s | each startTime asDateAndTime asLocal printSeparateDateAndTimeOn: s ] ]
]
