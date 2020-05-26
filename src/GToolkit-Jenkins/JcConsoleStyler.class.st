Class {
	#name : #JcConsoleStyler,
	#superclass : #BlTextStyler,
	#category : #'GToolkit-Jenkins'
}

{ #category : #accessing }
JcConsoleStyler >> classDependecesOn: aText [
	^ (#startOfLine asPParser
		, 'MetacelloNotification: Warning: This package depends on the following classes:' asPParser token 
		, #endOfLine asPParser negate star token 
		, #endOfLine asPParser) ==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5) ]
]

{ #category : #accessing }
JcConsoleStyler >> coreDumpedOn: aText [
	^ (#startOfLine asPParser
		, 'Aborted (core dumped)' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5) ]
]

{ #category : #accessing }
JcConsoleStyler >> deprecationOn: aText [
	^ (#startOfLine asPParser
		, 'DeprecationPerformedNotification: Automatic deprecation code rewrite: The method ' asPParser token
		, ' called from ' asPParser negate plus token
		, ' called from ' asPParser token
		, ' has been deprecated' asPParser negate plus token
		, ' has been deprecated' asPParser token
		, #endOfLine asPParser negate plus token
		, #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens second stop)
				highlight: self failureBackgroundColor.
			(aText from: tokens seventh start to: tokens seventh stop)
				highlight: self failureBackgroundColor.
			(aText from: tokens fourth start to: tokens fourth stop)
				highlight: self failureBackgroundColor.
			(aText from: tokens sixth start to: tokens sixth stop)
				highlight: self failureBackgroundColor.
			self includeMethodCoderIn: aText from: tokens third start to: tokens third stop underline: self failureBackgroundColor.
			self includeMethodCoderIn: aText from: tokens fifth start to: tokens fifth stop underline: self failureBackgroundColor.
			]
]

{ #category : #accessing }
JcConsoleStyler >> exceptionAccessViolationOn: aText [
	^ (#startOfLine asPParser
		, 'EXCEPTION_ACCESS_VIOLATION' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5) ]
]

{ #category : #accessing }
JcConsoleStyler >> executeActionFailureOn: aText [
	^ (#startOfLine asPParser
		,
			('GtRlExecuteActionSignal' asPParser / #endOfLine asPParser) negate
				plus token , 'GtRlExecuteActionSignal' asPParser
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			| color |
			color := (tokens fourth value includesSubstring: '[')
				ifTrue: [ BrGlamorousColors errorBackgroundColor alpha: 0.5 ]
				ifFalse: [ BrGlamorousColors successBackgroundColor alpha: 0.5 ].
			(aText from: tokens second start to: tokens fourth stop)
				highlight: color ]
]

{ #category : #accessing }
JcConsoleStyler >> exitOneParserOn: aText [
	^ (#startOfLine asPParser
		, 'script returned exit code 1' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5) ]
]

{ #category : #colors }
JcConsoleStyler >> failureBackgroundColor [
	^ BrGlamorousColors failureBackgroundColor alpha: 0.5
]

{ #category : #accessing }
JcConsoleStyler >> illegalInstructionOn: aText [
	^ (#startOfLine asPParser
		, 'Illegal instruction' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5) ]
]

{ #category : #'text attributes' }
JcConsoleStyler >> includeMethodCoderIn: aText from: aStart to: aStop [
	| aSubText aMethodDefinition aCompiledMethod |
	aSubText := aText from: aStart to: aStop.
	aMethodDefinition := GtSystemUtility methodDefinitionFromString: aSubText asString.
	aMethodDefinition isDefined ifFalse: [ ^ self ].
	aCompiledMethod := aMethodDefinition compiledMethod.
	aCompiledMethod ifNil: [ ^ self ].
	aSubText attribute:
		(BrTextExpandButtonAttribute new
				attributesCreatingBlock: [ BrTextAdornmentDynamicAttribute new
						beAppend;
						stencil: [ | editorElement coder |
							coder := GtMethodCoder forMethod: aCompiledMethod.
							coder subscribeToSystem.
							coder expanded: true.
							editorElement := coder asElement.
							editorElement
								border: (BlBorder paint: Color veryLightGray width: 1).
							editorElement
								margin:
									(BlInsets
										top: 3
										right: 10
										bottom: 10
										left: 10) ] ])
]

{ #category : #'text attributes' }
JcConsoleStyler >> includeMethodCoderIn: aText from: aStart to: aStop underline: aColor [
	self includeMethodCoderIn: aText from: aStart to: aStop.
	(aText from: aStart to: aStop)
		underlineDo: [ :anAttribute | anAttribute paint: aColor ].
]

{ #category : #accessing }
JcConsoleStyler >> metacelloNotificationFetched: aText [
	^ (#startOfLine asPParser
		, 'MetacelloNotification: Fetched' asPParser token
		, #endOfLine asPParser negate star token 
		, #endOfLine asPParser) ==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				foreground: (BrGlamorousColors defaultButtonTextColor alpha: 0.5) ]
]

{ #category : #accessing }
JcConsoleStyler >> metacelloNotificationLoaded: aText [
	^ (#startOfLine asPParser
		, 'MetacelloNotification: Loaded' asPParser token
		, #endOfLine asPParser negate star token 
		, #endOfLine asPParser) ==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				foreground: (BrGlamorousColors defaultButtonTextColor alpha: 0.5) ]
]

{ #category : #accessing }
JcConsoleStyler >> neutralOn: aText [
	^ (#startOfLine asPParser , '+' asPParser
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens third start - 1 to: tokens third stop)
				highlight: BrGlamorousColors neutralBackgroundColor ]
]

{ #category : #accessing }
JcConsoleStyler >> newUndeclaredOn: aText [
	^ (#startOfLine asPParser , 'NewUndeclaredWarning:' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				highlight: (BrGlamorousColors failureBackgroundColor alpha: 0.5) ]
]

{ #category : #accessing }
JcConsoleStyler >> privateStyle: aText [
	| parser |
	parser := (self metacelloNotificationFetched: aText)
		/ (self metacelloNotificationLoaded: aText)
		/ (self illegalInstructionOn: aText) 
		/ (self exceptionAccessViolationOn: aText)
		/ (self coreDumpedOn: aText)
		/ (self exitOneParserOn: aText)
		/ (self executeActionFailureOn: aText)
		/ (self segmentationFaultParserOn: aText)
		/ (self newUndeclaredOn: aText) 
		/ (self deprecationOn: aText)
		/ (self squareBracketErrorOn: aText)
		/ (self classDependecesOn: aText)
		/ (self neutralOn: aText).
	parser sea star optimize parse: aText asString.
	^ aText
]

{ #category : #accessing }
JcConsoleStyler >> segmentationFaultParserOn: aText [
	^ (#startOfLine asPParser , 'Segmentation fault' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5) ]
]

{ #category : #accessing }
JcConsoleStyler >> squareBracketErrorOn: aText [
	^ (#startOfLine asPParser , '[' asPParser token
		, #digit asPParser plus , 'm' asPParser
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens fifth stop)
				highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5) ]
]
