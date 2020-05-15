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
		, 'DeprecationPerformedNotification:' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				highlight: (BrGlamorousColors failureBackgroundColor alpha: 0.5) ]
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

{ #category : #accessing }
JcConsoleStyler >> illegalInstructionOn: aText [
	^ (#startOfLine asPParser
		, 'Illegal instruction' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5) ]
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
