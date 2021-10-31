Class {
	#name : #JcBlueJUnitStageTestCase,
	#superclass : #JcModelElement,
	#category : 'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanServiceEmbeddedRestJunit'
}

{ #category : #accessing }
JcBlueJUnitStageTestCase >> className [
	^ rawData at: 'className'
]

{ #category : #accessing }
JcBlueJUnitStageTestCase >> methodName [
	^ rawData at: 'name'
]

{ #category : #accessing }
JcBlueJUnitStageTestCase >> status [
	|result|
	result := 'SUCCESS'.
	((rawData at: 'status') ~= 'PASSED' ) ifTrue: [ 
		result := 'UNSTABLE'].
	^ result
]

{ #category : #accessing }
JcBlueJUnitStageTestCase >> statusBackgroundColor [
	^ JcJenkinsClient backgroundColorForStatus: self status
]
