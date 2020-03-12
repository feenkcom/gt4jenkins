Class {
	#name : #JcBlueJUnitTestResult,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanServiceEmbeddedRestJunit'
}

{ #category : #accessing }
JcBlueJUnitTestResult >> status [
	^ rawData at: 'status'
]

{ #category : #accessing }
JcBlueJUnitTestResult >> statusBackgroundColor [
	^ JcJenkinsClient backgroundColorForTestStatus: self status
]
