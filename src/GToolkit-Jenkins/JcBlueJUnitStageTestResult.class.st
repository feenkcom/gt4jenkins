Class {
	#name : #JcBlueJUnitStageTestResult,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanServiceEmbeddedRestJunit'
}

{ #category : #accessing }
JcBlueJUnitStageTestResult >> allCases [
	^ theModelBuilder modelFrom: (rawData at: 'cases') className: 'IoJenkinsBlueoceanServiceEmbeddedRestJunit.BlueJUnitStageTestCase'
]

{ #category : #accessing }
JcBlueJUnitStageTestResult >> gtAllCasesFor: aView [
	<gtView>
	| at|
	at := self allCases.
	at isEmpty ifTrue:[ ^ aView empty].
	^ aView columnedList
		title: 'All Cases' translated;
		priority: 60;
		items: [ at];
		column: 'Index' translated item: [ :eachItem :eachIndex | eachIndex asRopedText foreground: Color gray] width: 20;
		column: 'Status' translated do: [ :column | 
			column
				itemStencil: [ :each | BlElement new geometry: BlCircle new; background: each statusBackgroundColor; size: 10@10; margin: (BlInsets top: 5 left: 5 bottom: 5 right: 5) ];
				noResize ];
		column: 'Class' translated format: [ :eachItem | eachItem className] width: 350;
		column: 'Class' translated format: [ :eachItem | eachItem methodName] width: 250
]

{ #category : #accessing }
JcBlueJUnitStageTestResult >> status [
	|result|
	result := 'SUCCESS'.
	(rawData at: 'cases') collect: [:c | 
		(((c at:'status') = 'FAILED') and:[result = 'PASSED']) ifTrue: [ 
		result := 'UNSTABLE'].
	].
	^ result
]

{ #category : #accessing }
JcBlueJUnitStageTestResult >> statusBackgroundColor [
	^ JcJenkinsClient backgroundColorForStatus: self status
]

{ #category : #accessing }
JcBlueJUnitStageTestResult >> testClassName [
	^ rawData at: 'name'
]
