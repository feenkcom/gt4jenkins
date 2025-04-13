Class {
	#name : #JcConsoleStyler,
	#superclass : #BlTextStyler,
	#category : #'GToolkit-Jenkins'
}

{ #category : #accessing }
JcConsoleStyler >> archiveCreatingInflatingExtractingOn: aText [
	^ (#startOfLine asPParser
		, ('   creating: ' asPParser / '  inflating: ' asPParser / ' extracting: ' asPParser) token
		, #endOfLine asPParser negate star token 
		, #endOfLine asPParser) ==> [ :tokens | 
			(aText from: tokens second start to: tokens third stop)
				foreground: (BrGlamorousColors defaultButtonTextColor alpha: 0.5) ]
]

{ #category : #accessing }
JcConsoleStyler >> clonerBaselineSignalFaultParserOn: aText [
	^ (('GtRlClonerBaseline' asPParser , #space asPParser negate star flatten)
		token , '|' asPParser trim , 'ClonerEvent' asPParser token
		, '|' asPParser trim , #space asPParser negate star token
		, '|' asPParser trim , #space asPParser negate star token
		, '|' asPParser trim , #space asPParser negate star token)
		==> [ :tokens | 
			(aText from: tokens first start to: tokens first stop)
				highlight: (Color blue alpha: 0.1).
			(aText from: tokens fifth start to: tokens fifth stop)
				highlight: (Color blue alpha: 0.1).
			"(aText from: tokens seventh start to: tokens seventh stop)
				highlight: (Color blue alpha: 0.1)" ]
]

{ #category : #system }
JcConsoleStyler >> compiledMethodFrom: aString [
	| aMethodDefinition |
	aMethodDefinition := GtSystemUtility methodDefinitionFromString: aString.
	aMethodDefinition isDefined ifFalse: [ ^ nil ].
	^ aMethodDefinition compiledMethod
]

{ #category : #colors }
JcConsoleStyler >> defaultForegroundColor [
	^ Color black
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

{ #category : #colors }
JcConsoleStyler >> errorBackgroundColor [
	^ BrGlamorousColors errorBackgroundColor alpha: 0.5
]

{ #category : #accessing }
JcConsoleStyler >> exampleFailureOn: aText [
	"GtApServerInDockerExamples(GtApServerExamples) >> #publishPostOneWithTwoAttachmentPictures -- success
	GtApServerInDockerExamples(GtApServerExamples) >> #publishPostOneWithTwoAttachmentPictures -- failure"

	^ ('-- failure' asPParser token)
		==> [ :token | 
			(aText from: token start to: token stop)
				highlight: self errorBackgroundColor ]
]

{ #category : #accessing }
JcConsoleStyler >> exampleSuccessOn: aText [
	"GtApServerInDockerExamples(GtApServerExamples) >> #publishPostOneWithTwoAttachmentPictures -- success
	GtApServerInDockerExamples(GtApServerExamples) >> #publishPostOneWithTwoAttachmentPictures -- failure"

	^ ('-- success' asPParser token)
		==> [ :token | 
			(aText from: token start to: token stop)
				highlight: self successBackgroundColor ]
]

{ #category : #accessing }
JcConsoleStyler >> exceptionTextOn: aText [

	^ ('exception' asPParser token)
		==> [ :token | 
			(aText from: token start to: token stop)
				highlight: self errorBackgroundColor ]
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

{ #category : #colors }
JcConsoleStyler >> failureBackgroundColor [
	^ BrGlamorousColors failureBackgroundColor alpha: 0.5
]

{ #category : #'text attributes' }
JcConsoleStyler >> includeMethodCoderIn: aText from: aStart to: aStop [
	| aSubText aCompiledMethod |
	aSubText := aText from: aStart to: aStop.
	aCompiledMethod := self compiledMethodFrom: aSubText asString.
	aCompiledMethod ifNil: [ ^ self ].
	aSubText attribute:
		(BrGlamorousTriangleExpanderTextAttribute new
				attributesCreatingBlock: [ BrTextAdornmentDynamicAttribute new
						beAppend;
						stencil: [ | editorElement coder |
							coder := GtPharoMethodCoder forMethod: aCompiledMethod.
							coder subscribeToSystem.
							editorElement := (coder asCoderViewModel expanded: true) asElement.
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
	| aSubText aCompiledMethod |
	self includeMethodCoderIn: aText from: aStart to: aStop.
	aSubText := aText from: aStart to: aStop.
	aCompiledMethod := self compiledMethodFrom: aSubText asString.
	aCompiledMethod
		ifNotNil:
			[ aSubText underlineDo: [ :anAttribute | anAttribute color: aColor ] ]
		ifNil: [ aSubText highlight: aColor ]
]

{ #category : #parsers }
JcConsoleStyler >> isoDateParser [

	"Parser for YYYY-MM-DD, e.g., 2021-09-03"

	^ (#digit asPParser times: 4) token , '-' asPParser
	  , (#digit asPParser times: 2) token , '-' asPParser
	  , (#digit asPParser times: 2) token
]

{ #category : #parsers }
JcConsoleStyler >> isoTimeParser [

	"Parser for HH:MM:SS, e.g., 17:03:59"
	
	^ (#digit asPParser times: 2) token , ':' asPParser
	  , (#digit asPParser times: 2) token , ':' asPParser
	  , (#digit asPParser times: 2) token
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

	^ #startOfLine asPParser
	  , 'MetacelloNotification: Loaded' asPParser token
	  , #endOfLine asPParser negate star token , #endOfLine asPParser
	  ==> [ :tokens | 
		  (aText from: tokens second start to: tokens third stop) 
			  foreground: self neutralForegroundColor ]
]

{ #category : #colors }
JcConsoleStyler >> neutralBackgroundColor [
	^ BrGlamorousColors neutralBackgroundColor
]

{ #category : #colors }
JcConsoleStyler >> neutralForegroundColor [

	^ BrGlamorousColors defaultButtonTextColor alpha: 0.5
]

{ #category : #accessing }
JcConsoleStyler >> neutralOn: aText [
	^ (#startOfLine asPParser , '+' asPParser
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens third start - 1 to: tokens third stop)
				highlight: self neutralBackgroundColor ]
]

{ #category : #accessing }
JcConsoleStyler >> neutralOnPendingFuturePromiseState: aText [
	^ ('Pending future promise state: ' asPParser token)
		==> [ :tokens | 
			(aText from: tokens start - 1 to: tokens stop)
				highlight: self neutralBackgroundColor ]
]

{ #category : #accessing }
JcConsoleStyler >> newUndeclaredOn: aText [
	^ (#startOfLine asPParser 
		, 'NewUndeclaredWarning: ' asPParser token
		, ' ' asPParser negate plus token
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens second start to: tokens second stop)
				highlight: self failureBackgroundColor.
			(aText from: tokens fourth start to: tokens fourth stop)
				underlineDo: [ :anAttribute | anAttribute color: self failureBackgroundColor ].
			self includeMethodCoderIn: aText from: tokens third start to: tokens third stop underline: self failureBackgroundColor ]
]

{ #category : #accessing }
JcConsoleStyler >> patternsParser: aText [
	^ (JcConsoleProblemsScanner new
		==> [ :each | 
			| tokens |
			each isToken
				ifTrue: [ (aText from: each start to: each stop)
						highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5) ]
				ifFalse: [ tokens := each select: #isToken. 
					(aText from: tokens first start to: tokens last stop)
						highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5) ] ])
		/ (self metacelloNotificationFetched: aText)
		/ (self metacelloNotificationLoaded: aText)
		/ (self executeActionFailureOn: aText)
		/ (self newUndeclaredOn: aText) 
		/ (self shadowedVariableOn: aText)
		/ (self deprecationOn: aText)
		/ (self archiveCreatingInflatingExtractingOn: aText)
		/ (self postgresNeutralLog: aText) 
		/ (self neutralOn: aText)
		/ (self exampleSuccessOn: aText) 
		/ (self exceptionTextOn: aText)
		/ (self exampleFailureOn: aText)
		/ (self clonerBaselineSignalFaultParserOn: aText)
		/ (self neutralOnPendingFuturePromiseState: aText)
]

{ #category : #accessing }
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

{ #category : #parsers }
JcConsoleStyler >> postgresTimeStampParser [

	^ #startOfLine asPParser , self isoDateParser , ' ' asPParser
	  , self isoTimeParser , ' ' asPParser , #digit asPParser plus token
	  , ' [P3] ' asPParser , #digit asPParser plus token
]

{ #category : #accessing }
JcConsoleStyler >> privateStyle: aText [
	| parser aString |
	aString := aText asString.
	parser := self patternsParser: aText.
	parser sea star optimize parse: aString.
	^ aText
]

{ #category : #accessing }
JcConsoleStyler >> shadowedVariableOn: aText [
	^ ('SystemNotification: ' asPParser token 
		, '(' asPParser negate plus token
		, '(' asPParser token 
		, ' is shadowed)' asPParser negate plus token
		, ' is shadowed)' asPParser token
		, #endOfLine asPParser)
		==> [ :tokens | 
			(aText from: tokens first start to: tokens first stop)
				highlight: self failureBackgroundColor.
				
			(aText from: tokens third start to: tokens fifth stop)
				highlight: self failureBackgroundColor.
				
			self includeMethodCoderIn: aText from: tokens second start to: tokens second stop underline: self failureBackgroundColor ]
]

{ #category : #colors }
JcConsoleStyler >> successBackgroundColor [
	^ BrGlamorousColors successBackgroundColor alpha: 0.5
]
