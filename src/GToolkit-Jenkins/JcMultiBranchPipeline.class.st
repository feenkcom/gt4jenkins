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
		items: [ self branches];
		column: 'Status' translated do: [ :column | 
			column
				itemStencil: [ :each | BlElement new geometry: BlCircle new; background: each resultBackgroundColor; size: 10@10; margin: (BlInsets top: 5 left: 5 bottom: 5 right: 5) ];
				noResize ];
		column: 'Branch' translated format: [ :each | each gtDisplayText ] width: 110;
		column: 'Last duration' translated format: [ :each | (each duration roundTo: 1 second) humanReadablePrintString ] width: 150;
		column: 'Last run start time' translated format: [ :each | String streamContents: [:s | each startTime asDateAndTime asLocal printSeparateDateAndTimeOn: s ]]
]
