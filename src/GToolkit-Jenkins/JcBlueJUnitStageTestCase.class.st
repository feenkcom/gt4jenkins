Class {
	#name : #JcBlueJUnitStageTestCase,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanServiceEmbeddedRestJunit'
}

{ #category : #accessing }
JcBlueJUnitStageTestCase >> className [
	^ rawData at: 'className'
]

{ #category : #accessing }
JcBlueJUnitStageTestCase >> compiledMethod [
	^ self realClass
		ifNotNil: [ :aClass | 
			(aClass includesSelector: self methodName asSymbol)
				ifTrue: [ aClass compiledMethodAt: self methodName asSymbol ]
				ifFalse: [ nil ] ]
]

{ #category : #accessing }
JcBlueJUnitStageTestCase >> duration [
	^ self
		atPath: #(duration)
		ifPresent: #yourself
		ifAbsent: [ nil ]
]

{ #category : #'gt - extensions' }
JcBlueJUnitStageTestCase >> gtCompiledMethodFor: aView [
	<gtView>
	| aCompiledMethod |
	aCompiledMethod := self compiledMethod.
	aCompiledMethod ifNil: [ ^ aView empty ].

	^ aView explicit
		title: 'Method';
		priority: 1;
		stencil: [ (GtPharoMethodCoder
				forMethod: (self compiledMethod ifNil: [ aCompiledMethod ]))
				asExpandedOnlyElement vFitContentLimited ]
]

{ #category : #accessing }
JcBlueJUnitStageTestCase >> methodName [
	^ rawData at: 'name'
]

{ #category : #printing }
JcBlueJUnitStageTestCase >> printOn: aStream [
	super printOn: aStream.

	aStream nextPut: $(.
	self shortClassName ifNotNil: [ :aName | aStream nextPutAll: aName ].

	self methodName
		ifNotNil: [ :aName | 
			aStream nextPutAll: '>>#'.
			aStream nextPutAll: aName ].
	aStream nextPut: $)
]

{ #category : #accessing }
JcBlueJUnitStageTestCase >> realClass [
	^ self class environment 
		at: self shortClassName asSymbol 
		ifAbsent: [ nil ]
]

{ #category : #accessing }
JcBlueJUnitStageTestCase >> shortClassAndMethodName [
	^ self shortClassName , '>>#' , self methodName
]

{ #category : #accessing }
JcBlueJUnitStageTestCase >> shortClassName [
	^ self
		atPath: #(className)
		ifPresent: [ :aName | ($. split: aName) last ]
		ifAbsent: [ nil ]
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
	^ JcJenkinsClient backgroundColorForResult: self status
]
