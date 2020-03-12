Class {
	#name : #JcBlueJUnitTestResult,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanServiceEmbeddedRestJunit'
}

{ #category : #'as yet unclassified' }
JcBlueJUnitTestResult class >> testStatusParser [
	|method fullClass p|
	method := #word asPParser plus flatten.
	fullClass := (#word asPParser plus flatten separatedBy: '.' asPParser) ==> #last.
	p := ((
		((method, (Character value: 8211) asPParser trim, fullClass) ==> [:t | t third -> t first])
		/ 
		'/' asPParser negate star flatten) 
		separatedBy: '/' asPParser trim)
		==> [:t | t reject: [:each | each = '/']].
	^ p optimize
]

{ #category : #accessing }
JcBlueJUnitTestResult >> fullStageName [
	^ '/ ' join: self testNameParsed allButLast 
]

{ #category : #accessing }
JcBlueJUnitTestResult >> gtDisplayOn: stream [
	stream nextPutAll: self name
]

{ #category : #testing }
JcBlueJUnitTestResult >> isFailed [
	^ self status = 'FAILED'
]

{ #category : #testing }
JcBlueJUnitTestResult >> isPassed [
	^ self status = 'PASSED'
]

{ #category : #accessing }
JcBlueJUnitTestResult >> name [ 
	^ rawData at: 'name'
]

{ #category : #accessing }
JcBlueJUnitTestResult >> status [
	^ rawData at: 'status'
]

{ #category : #accessing }
JcBlueJUnitTestResult >> statusBackgroundColor [
	^ JcJenkinsClient backgroundColorForTestStatus: self status
]

{ #category : #accessing }
JcBlueJUnitTestResult >> testClassName [
	^ self testNameParsed last key
]

{ #category : #accessing }
JcBlueJUnitTestResult >> testMethod [
	^ self testClassName asClass >> self testMethodName asSymbol 
]

{ #category : #accessing }
JcBlueJUnitTestResult >> testMethodName [
	^ self testNameParsed last value
]

{ #category : #accessing }
JcBlueJUnitTestResult >> testNameParsed [
	^ self class testStatusParser parse: self name
]
