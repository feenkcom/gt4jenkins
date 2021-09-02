Class {
	#name : 'JcJcBlueJUnitStageTestResult',
	#superclass : 'JcModelElement',
	#category : 'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanServiceEmbeddedRestJunit'
}

{ #category : 'accessing' }
JcJcBlueJUnitStageTestResult >> resultBackgroundColor [
	^ JcJenkinsClient backgroundColorForStatus: self result
]

{ #category : 'accessing' }
JcJcBlueJUnitStageTestResult >> status [
	|result|
	result := 'SUCCESS'.
	(rawData at: 'cases') collect: [:c | 
		(((c at:'status') = 'FAILED') and:[result = 'PASSED']) ifTrue: [ 
		result := 'UNSTABLE'].
	].
	^ result
]

{ #category : 'accessing' }
JcJcBlueJUnitStageTestResult >> statusBackgroundColor [
	^ JcJenkinsClient backgroundColorForStatus: self status
]
