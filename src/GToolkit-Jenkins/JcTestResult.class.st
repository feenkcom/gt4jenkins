Class {
	#name : #JcTestResult,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins'
}

{ #category : #accessing }
JcTestResult >> rawSuites [
	^ rawData at: 'suites'
]
