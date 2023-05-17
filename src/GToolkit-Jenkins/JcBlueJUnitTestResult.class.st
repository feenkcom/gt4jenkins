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
JcBlueJUnitTestResult >> errorDetails [
	<return: #String>
	^ self rawData
		at: 'errorDetails'
		ifPresent: [ :aValue | aValue asString ]
		ifAbsent: [ String empty ]
]

{ #category : #accessing }
JcBlueJUnitTestResult >> errorStackTrace [
	<return: #String>
	^ self rawData
		at: 'errorStackTrace'
		ifPresent: [ :aValue | aValue asString ]
		ifAbsent: [ String empty ]
]

{ #category : #accessing }
JcBlueJUnitTestResult >> fullStageName [
	^ '/ ' join: self testNameParsed allButLast 
]

{ #category : #accessing }
JcBlueJUnitTestResult >> gtDisplayOn: stream [
	stream nextPutAll: self name
]

{ #category : #accessing }
JcBlueJUnitTestResult >> gtErrorDetailsFor: aView [ 
	<gtView>
	self isPassed ifTrue: [ ^ aView empty ].
	^ aView textEditor
		title: 'Error details';
		priority: 4;
		aptitude: [ BrGlamorousRegularEditorAptitude ];
		text: [
			| aText |
			aText := 'Details' asRopedText bold.
			aText append: String cr asRopedText.
			
			aText append: self errorDetails asRopedText.
			aText append: String cr asRopedText.
			aText append: String cr asRopedText.
			
			aText append: 'Stack' asRopedText bold.
			aText append: String cr asRopedText.
			aText append: self errorStackTrace asRopedText ]
]

{ #category : #accessing }
JcBlueJUnitTestResult >> gtTestFor: aView [
	<gtView>
	self testMethod 
		ifNotNil: [ :aMethod | ^ aMethod gtSourceFor: aView ].
	^ aView textEditor 
		title: 'Not found';
		glamorousRegularFontAndSize;
		text: [ String streamContents: [ :aStream | 
			aStream 
				nextPutAll: 'Source code not found:'; cr;
				nextPutAll: ' - class: '; print: self testClassName; cr;
				nextPutAll: ' - method: '; print: self testMethodName; cr ] ]
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
	| aClassName |
	aClassName := self testNameParsed last.
	^ aClassName isString 
		ifTrue: [ aClassName ] 
		ifFalse: [ aClassName key ]
]

{ #category : #accessing }
JcBlueJUnitTestResult >> testMethod [
	<return: #CompiledMethod or: nil>
	| aClass aSelector aMethod |
	aClass := self testClassName asClassIfAbsent: [ ^ nil ].
	aSelector := self testMethodName asSymbol.
	aMethod := aClass instanceSide lookupSelector: aSelector.
	^ aMethod ifNil: [
		aClass classSide lookupSelector: aSelector ]
]

{ #category : #accessing }
JcBlueJUnitTestResult >> testMethodName [
	^ self testNameParsed last value
]

{ #category : #accessing }
JcBlueJUnitTestResult >> testNameParsed [
	^ self class testStatusParser parse: self name
]
