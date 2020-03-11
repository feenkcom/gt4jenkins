Class {
	#name : #JcModelBuilder,
	#superclass : #Object,
	#instVars : [
		'packageOrganizer',
		'jenkinsClient'
	],
	#category : #'GToolkit-Jenkins'
}

{ #category : #accessing }
JcModelBuilder >> ensureClass: aFullClassName [
	|fullPackageName classSymbol |
	fullPackageName := (aFullClassName findTokens: '.') allButLast 
		fold:[:first :second | first capitalized, second capitalized].
	fullPackageName := 'GToolkit-Jenkins-Generated-',fullPackageName.
	self ensurePackage: fullPackageName.
	classSymbol := (aFullClassName findTokens: '.') last.
	classSymbol := classSymbol copyReplaceAll: '$' with: '_'.
	classSymbol := classSymbol copyReplaceAll: 'Impl' with: ''.
	classSymbol := 'Jc', classSymbol.
	^ classSymbol asClassInEnvironment: Smalltalk globals 
		ifAbsent: [ (JcModelElement subclass: classSymbol)
								  category: fullPackageName ].
]

{ #category : #accessing }
JcModelBuilder >> ensurePackage: aFullPackageName [
	^ packageOrganizer ensureExistAndRegisterPackageNamed: aFullPackageName
]

{ #category : #accessing }
JcModelBuilder >> initialize [ 
	packageOrganizer := RPackageOrganizer new.
]

{ #category : #accessing }
JcModelBuilder >> jenkinsClient [
	^ jenkinsClient
]

{ #category : #accessing }
JcModelBuilder >> jenkinsClient: aJenkinsClient [
	jenkinsClient := aJenkinsClient
	
]

{ #category : #accessing }
JcModelBuilder >> modelFrom: aDictionary [
	| theClass theObject theArray|
	aDictionary isArray ifTrue: [
	theArray := OrderedCollection new.
	aDictionary collect: [:each | theArray add: (self modelFrom: each)].
	^ theArray].
	aDictionary at: #'_class' ifPresent: [:fullClassName | 
		theClass := (self ensureClass: fullClassName).
		theObject := theClass new.
		theObject modelBuilder: self.
		theObject json: aDictionary.
		^ theObject].
	^ nil
	
]
