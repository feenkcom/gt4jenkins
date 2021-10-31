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
	| at |
	at := self allCases.
	at isEmpty
		ifTrue: [ ^ aView empty ].
	^ aView columnedList
		title: 'All Cases' translated;
		priority: 60;
		items: [ at ];
		column: 'Index' translated
			text:
				[ :eachItem :eachIndex | eachIndex asRopedText foreground: Color gray ]
			width: 20;
		column: 'Status' translated
			icon: [ :each | 
			BlElement new
				geometry: BlCircleGeometry new;
				background: each statusBackgroundColor;
				size: 10 @ 10 ]
			width: 50;
		column: 'Class' translated
			text: [ :eachItem | eachItem className ]
			width: 350;
		column: 'Method' translated
			text: [ :eachItem | eachItem methodName ]
			width: 250
]

{ #category : #accessing }
JcBlueJUnitStageTestResult >> status [
	|result|
	result := 'SUCCESS'.
	(rawData at: 'cases') detect: [:d | (d at: 'status') ~= 'PASSED'] ifFound: [result := 'UNSTABLE'] ifNone: [result := 'SUCCESS'.].
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
