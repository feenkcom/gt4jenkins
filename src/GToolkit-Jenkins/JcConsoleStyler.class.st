Class {
	#name : 'JcConsoleStyler',
	#superclass : 'BlTextStyler',
	#category : 'GToolkit-Jenkins'
}

{ #category : 'accessing' }
JcConsoleStyler >> archiveCreatingInflatingExtractingOn: aText [
	^ (#startOfLine asPParser
		, ('   creating: ' asPParser / '  inflating: ' asPParser / ' extracting: ' asPParser) token
		, #endOfLine asPParser negate star token 
		, #endOfLine asPParser) ==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				foreground: (BrGlamorousColors defaultButtonTextColor alpha: 0.5) ]
]

{ #category : 'accessing' }
JcConsoleStyler >> bashError: aText [
	^ (#startOfLine asPParser
		, 'bash: line ' asPParser token
		, #digit asPParser plus
		, ': ' asPParser
		, #endOfLine asPParser negate plus token
		, #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens fifth stop)
				highlight: self errorBackgroundColor ]
]

{ #category : 'accessing' }
JcConsoleStyler >> brackettedErrorOn: aText [ 
	^ ('[ERROR]' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens first start to: tokens second stop)
				highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5) ]
]

{ #category : 'accessing' }
JcConsoleStyler >> classDependecesOn: aText [
	^ (#startOfLine asPParser
		, 'MetacelloNotification: Warning: This package depends on the following classes:' asPParser token 
		, #endOfLine asPParser negate star token 
		, #endOfLine asPParser) ==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5) ]
]

{ #category : 'system' }
JcConsoleStyler >> compiledMethodFrom: aString [
	| aMethodDefinition |
	aMethodDefinition := GtSystemUtility methodDefinitionFromString: aString.
	aMethodDefinition isDefined ifFalse: [ ^ nil ].
	^ aMethodDefinition compiledMethod
]

{ #category : 'accessing' }
JcConsoleStyler >> consoleErrorSequenceOn: aText [
	^ (Character escape asPParser token
		, '[31m' asPParser token
		, Character escape asPParser negate star token
		, Character escape asPParser token
		, '[0m' asPParser token
		, Character escape asPParser negate star token
		, Character escape asPParser token
		, '[0m' asPParser token
		)
		==> [ :tokens | 
			(aText from: tokens first start to: tokens second stop)
				replacingAdornment: [ :aPiece :aEDitorElement | #() ].
			(aText from: tokens third start to: tokens third stop)
				highlight: self errorBackgroundColor.
			(aText from: tokens fourth start to: tokens fifth stop)
				replacingAdornment: [ :aPiece :aEDitorElement | #() ].
			(aText from: tokens sixth start to: tokens sixth stop)
				underlineColor: self errorBackgroundColor.
			(aText from: tokens seventh start to: tokens eighth stop)
				replacingAdornment: [ :aPiece :aEDitorElement | #() ] ].
]

{ #category : 'accessing' }
JcConsoleStyler >> coreDumpedOn: aText [
	^ (#startOfLine asPParser
		, 'Aborted (core dumped)' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5) ]
]

{ #category : 'colors' }
JcConsoleStyler >> defaultForegroundColor [
	^ Color black
]

{ #category : 'accessing' }
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

{ #category : 'colors' }
JcConsoleStyler >> errorBackgroundColor [
	^ BrGlamorousColors errorBackgroundColor alpha: 0.5
]

{ #category : 'accessing' }
JcConsoleStyler >> exceptionAccessViolationOn: aText [
	^ (#startOfLine asPParser
		, 'EXCEPTION_ACCESS_VIOLATION' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5) ]
]

{ #category : 'accessing' }
JcConsoleStyler >> exceptionIllegalInstructionOn: aText [
	^ (#startOfLine asPParser
		, 'EXCEPTION_ILLEGAL' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5) ]
]

{ #category : 'accessing' }
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

{ #category : 'accessing' }
JcConsoleStyler >> exitOneParserOn: aText [
	^ (#startOfLine asPParser
		, 'script returned exit code 1' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5) ]
]

{ #category : 'colors' }
JcConsoleStyler >> failureBackgroundColor [
	^ BrGlamorousColors failureBackgroundColor alpha: 0.5
]

{ #category : 'accessing' }
JcConsoleStyler >> hardSpaceOn: aText [
	"ASCII value 160"
	^ ' ' asPParser plus token
		==> [ :token | 
				(aText from: token start to: token stop)
					highlight: (self failureBackgroundColor alpha: 0.75) ]
]

{ #category : 'accessing' }
JcConsoleStyler >> illegalInstructionOn: aText [
	^ (#startOfLine asPParser
		, 'Illegal instruction' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5) ]
]

{ #category : 'text attributes' }
JcConsoleStyler >> includeMethodCoderIn: aText from: aStart to: aStop [
	| aSubText aCompiledMethod |
	aSubText := aText from: aStart to: aStop.
	aCompiledMethod := self compiledMethodFrom: aSubText asString.
	aCompiledMethod ifNil: [ ^ self ].
	aSubText attribute:
		(BrGlamorousTrangleExpanderTextAttribute new
				attributesCreatingBlock: [ BrTextAdornmentDynamicAttribute new
						beAppend;
						stencil: [ | editorElement coder |
							coder := GtPharoMethodCoder forMethod: aCompiledMethod.
							coder subscribeToSystem.
							editorElement := (coder asCoderUIModel expanded: true) asElement.
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

{ #category : 'text attributes' }
JcConsoleStyler >> includeMethodCoderIn: aText from: aStart to: aStop underline: aColor [
	| aSubText aCompiledMethod |
	self includeMethodCoderIn: aText from: aStart to: aStop.
	aSubText := aText from: aStart to: aStop.
	aCompiledMethod := self compiledMethodFrom: aSubText asString.
	aCompiledMethod
		ifNotNil:
			[ aSubText underlineDo: [ :anAttribute | anAttribute color: aColor ] ]
		ifNil: [ aSubText highlight: aColor ]
]

{ #category : 'parsers' }
JcConsoleStyler >> isoDateParser [

	"Parser for YYYY-MM-DD, e.g., 2021-09-03"

	^ (#digit asPParser times: 4) token , '-' asPParser
	  , (#digit asPParser times: 2) token , '-' asPParser
	  , (#digit asPParser times: 2) token
]

{ #category : 'parsers' }
JcConsoleStyler >> isoTimeParser [

	"Parser for HH:MM:SS, e.g., 17:03:59"
	
	^ (#digit asPParser times: 2) token , ':' asPParser
	  , (#digit asPParser times: 2) token , ':' asPParser
	  , (#digit asPParser times: 2) token
]

{ #category : 'accessing' }
JcConsoleStyler >> jenkinsError: aText [
	^ (#startOfLine asPParser
		, '[ERROR]' asPParser token
		, #endOfLine asPParser negate plus token
		, #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				highlight: self errorBackgroundColor ]
]

{ #category : 'accessing' }
JcConsoleStyler >> makeErrorOn: aText [
	^ (#startOfLine asPParser
		, 'make: ***' asPParser token
		, ' Error ' asPParser negate star 
		, ' Error ' asPParser
		, #digit asPParser plus token
		, #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens fifth stop)
				highlight: self errorBackgroundColor ]
]

{ #category : 'accessing' }
JcConsoleStyler >> makefileFailedOn: aText [
	^ (#startOfLine asPParser
		, 'Makefile:' asPParser token
		, ' failed' asPParser negate plus
		, ' failed' asPParser token
		, #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens fourth stop)
				highlight: self errorBackgroundColor ]
]

{ #category : 'accessing' }
JcConsoleStyler >> metacelloNotificationFetched: aText [
	^ (#startOfLine asPParser
		, 'MetacelloNotification: Fetched' asPParser token
		, #endOfLine asPParser negate star token 
		, #endOfLine asPParser) ==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				foreground: (BrGlamorousColors defaultButtonTextColor alpha: 0.5) ]
]

{ #category : 'accessing' }
JcConsoleStyler >> metacelloNotificationLoaded: aText [

	^ #startOfLine asPParser
	  , 'MetacelloNotification: Loaded' asPParser token
	  , #endOfLine asPParser negate star token , #endOfLine asPParser
	  ==> [ :tokens | 
		  (aText from: tokens second start to: tokens third stop) 
			  foreground: self neutralForegroundColor ]
]

{ #category : 'colors' }
JcConsoleStyler >> neutralBackgroundColor [
	^ BrGlamorousColors neutralBackgroundColor
]

{ #category : 'colors' }
JcConsoleStyler >> neutralForegroundColor [

	^ BrGlamorousColors defaultButtonTextColor alpha: 0.5
]

{ #category : 'accessing' }
JcConsoleStyler >> neutralOn: aText [
	^ (#startOfLine asPParser , '+' asPParser
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens third start - 1 to: tokens third stop)
				highlight: self neutralBackgroundColor ]
]

{ #category : 'accessing' }
JcConsoleStyler >> newUndeclaredOn: aText [
	^ (#startOfLine asPParser 
		, 'NewUndeclaredWarning: ' asPParser token
		, ' ' asPParser negate plus token
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens second stop)
				highlight: self failureBackgroundColor.
			(aText from: tokens fourth start to: tokens fourth stop)
				highlight: self failureBackgroundColor.
			self includeMethodCoderIn: aText from: tokens third start to: tokens third stop underline: self failureBackgroundColor ]
]

{ #category : 'accessing' }
JcConsoleStyler >> postgresError: aText [

	^ self postgresTimeStampParser , ' #Error' asPParser token
	  , #endOfLine asPParser negate plus token , #endOfLine asPParser
	  ==> [ :tokens | 
		  (aText
			   from: tokens second first start
			   to: (tokens at: tokens size - 1) stop) highlight:
			  self errorBackgroundColor ]
]

{ #category : 'accessing' }
JcConsoleStyler >> postgresNeutralLog: aText [

	^ self postgresTimeStampParser
	  , (' #Query' asPParser token | ' #Prepare' asPParser token
		   | ' #Bind' asPParser token | ' #Result' asPParser token
		   | ' #Close' asPParser token)
	  , #endOfLine asPParser negate star token , #endOfLine asPParser
	  ==> [ :tokens | 
		  (aText
			   from: tokens second first start
			   to: (tokens at: tokens size - 1) stop) foreground:
			  self neutralForegroundColor ]
]

{ #category : 'parsers' }
JcConsoleStyler >> postgresTimeStampParser [

	^ #startOfLine asPParser , self isoDateParser , ' ' asPParser
	  , self isoTimeParser , ' ' asPParser , #digit asPParser plus token
	  , ' [P3] ' asPParser , #digit asPParser plus token
]

{ #category : 'accessing' }
JcConsoleStyler >> privateStyle: aText [

	| parser aString |
	aString := aText asString.
	parser := (self vmErrorOn: aText) / (self brackettedErrorOn: aText)
	          / (self consoleErrorSequenceOn: aText)
	          / (self metacelloNotificationFetched: aText)
	          / (self metacelloNotificationLoaded: aText)
	          / (self illegalInstructionOn: aText)
	          / (self exceptionIllegalInstructionOn: aText)
	          / (self exceptionAccessViolationOn: aText)
	          / (self coreDumpedOn: aText)
	          / (self exitOneParserOn: aText)
	          / (self executeActionFailureOn: aText)
	          / (self newUndeclaredOn: aText)
	          / (self deprecationOn: aText)
	          / (self squareBracketErrorOn: aText)
	          / (self classDependecesOn: aText)
	          / (self archiveCreatingInflatingExtractingOn: aText)
	          / (self makeErrorOn: aText)
	          / (self makefileFailedOn: aText) / (self shellError: aText)
	          / (self jenkinsError: aText) / (self bashError: aText)
	          / (self postgresError: aText)
	          / (self postgresNeutralLog: aText)
	          / (self neutralOn: aText).
	parser sea star optimize parse: aString.

	(self segmentationFaultParserOn: aText) sea star optimize parse:
		aString.
	(self hardSpaceOn: aText) sea star optimize parse: aString.
	^ aText
]

{ #category : 'accessing' }
JcConsoleStyler >> segmentationFaultParserOn: aText [
	^ ('Segmentation fault' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens first start to: tokens second stop)
				foreground: self defaultForegroundColor;
				highlight: self errorBackgroundColor ]
]

{ #category : 'accessing' }
JcConsoleStyler >> shellError: aText [
	^ (#startOfLine asPParser
		, '/bin/sh: ' asPParser token
		, #digit asPParser plus
		, ': ' asPParser
		, #endOfLine asPParser negate plus token
		, #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens fifth stop)
				highlight: self errorBackgroundColor ]
]

{ #category : 'accessing' }
JcConsoleStyler >> squareBracketErrorOn: aText [
	^ (#startOfLine asPParser , '[' asPParser token
		, #digit asPParser plus , 'm' asPParser
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens fifth stop)
				highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5) ]
]

{ #category : 'accessing' }
JcConsoleStyler >> vmErrorOn: aText [ 
	^ (#startOfLine asPParser
		, 'VM Error' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5) ]
]
