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
JcBlueJUnitStageTestResult >> duration [
	^ self
		atPath: #(duration)
		ifPresent: #yourself
		ifAbsent: [ nil ]
]

{ #category : #accessing }
JcBlueJUnitStageTestResult >> gtAllCasesFor: aView [
	<gtView>
	| at |
	at := self allCases.
	at isEmpty
		ifTrue: [ ^ aView empty ].
	^ aView columnedList
		title: 'All cases' translated;
		priority: 60;
		items: [ at ];
		column: '' translated
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
			weight: 3;
		column: 'Method' translated
			text: [ :eachItem | eachItem methodName ]
			weight: 2;
		column: 'Duration' translated
			text: [ :eachItem | eachItem duration ]
			width: 65
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
	^ JcJenkinsClient backgroundColorForResult: self status
]

{ #category : #accessing }
JcBlueJUnitStageTestResult >> testClassName [
	^ rawData at: 'name'
]
