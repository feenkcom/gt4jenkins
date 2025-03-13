Class {
	#name : #JcConsoleProblemsScanner,
	#superclass : #PP2CompositeNode,
	#instVars : [
		'brackettedError',
		'consoleErrorSequence',
		'coreDumped',
		'errorExpectedVersionMismatch',
		'exceptionAccessViolationToEndOfLine',
		'exceptionIllegalInstruction',
		'failedCommandToEndOfLine',
		'failedToDetectGTVersion',
		'illegalInstructionToEndOfLine',
		'vmError',
		'exitOneParser',
		'squareBracketAtStartOfLineError',
		'metacelloUnloadableClasses',
		'makeError',
		'makefileFailed',
		'shellError',
		'jenkinsError',
		'bashError',
		'isoDateParser',
		'isoTimeParser',
		'postgresTimeStampParser',
		'postgresError',
		'anErrorText',
		'serverErrorText',
		'exceptionText',
		'exampleFailure',
		'segmentationFault',
		'hardSpace',
		'httpError',
		'errorToEndOfLine',
		'javaLangInterruptedException',
		'sendingInterruptSignalToProcess',
		'gemstoneCompilerErrors'
	],
	#category : #'GToolkit-Jenkins'
}

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> anErrorText [
	^ 'an error' asPParser token
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> bashError [
	^ #startOfLine asPParser , 'bash: line ' asPParser token
		, #digit asPParser plus , ': ' asPParser
		, #endOfLine asPParser negate plus token , #endOfLine asPParser
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> brackettedError [
	^ '[ERROR]' asPParser token , #endOfLine asPParser negate star token
		, #endOfLine asPParser
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> consoleErrorSequence [
	^ Character escape asPParser token , '[31m' asPParser token
		, Character escape asPParser negate star token
		, Character escape asPParser token , '[0m' asPParser token
		, Character escape asPParser negate star token
		, Character escape asPParser token , '[0m' asPParser token
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> coreDumped [
	^ #startOfLine asPParser , 'Aborted (core dumped)' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> errorExpectedVersionMismatch [
	^ 'Error: Expected version' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> errorToEndOfLine [
	^ '[97;41;22mError:[91;49;1m' asPParser token
		, #endOfLine asPParser negate star token
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> exampleFailure [
	"GtApServerInDockerExamples(GtApServerExamples) >> #publishPostOneWithTwoAttachmentPictures -- success
	GtApServerInDockerExamples(GtApServerExamples) >> #publishPostOneWithTwoAttachmentPictures -- failure"

	^ ('-- failure' asPParser token)
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> exceptionAccessViolationToEndOfLine [
	^ (#startOfLine asPParser
		, 'EXCEPTION_ACCESS_VIOLATION' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser)
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> exceptionIllegalInstruction [
	^ (#startOfLine asPParser token
		, 'EXCEPTION_ILLEGAL' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser token)
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> exceptionText [

	^ (' exception' asPParser token)
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> exitOneParser [
	^ (#startOfLine asPParser token
		, 'script returned exit code 1' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser token)
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> failedCommandToEndOfLine [
	^ ('Failed command' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser token)
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> failedToDetectGTVersion [
	^ 'Failed to detect the version of the gtoolkit' asPParser token
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> gemstoneCompilerErrors [
	^ 'GemStone Smalltalk Compiler Errors' asPParser token
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> hardSpace [
	"ASCII value 160"
	^ ' ' asPParser plus token
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> httpError [
	^ 'Error: HTTP status code:' asPParser token
		, #endOfLine asPParser negate star token
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> illegalInstructionToEndOfLine [
	^ (#startOfLine asPParser token
		, 'Illegal instruction' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser token)
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> isoDateParser [
	"Parser for YYYY-MM-DD, e.g., 2021-09-03"

	^ (#digit asPParser times: 4) token , '-' asPParser token
		, (#digit asPParser times: 2) token , '-' asPParser token
		, (#digit asPParser times: 2) token
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> isoTimeParser [

	"Parser for HH:MM:SS, e.g., 17:03:59"
	
	^ (#digit asPParser times: 2) token , ':' asPParser
	  , (#digit asPParser times: 2) token , ':' asPParser
	  , (#digit asPParser times: 2) token
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> javaLangInterruptedException [
	^ ('java.lang.InterruptedException' asPParser token
		, #endOfLine asPParser token)
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> jenkinsError [
	^ #startOfLine asPParser token , '[ERROR]' asPParser token
		, #endOfLine asPParser negate plus token , #endOfLine asPParser token
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> makeError [
	^ #startOfLine asPParser token , 'make: ***' asPParser token
		, ' Error ' asPParser negate star token , ' Error ' asPParser token
		, #digit asPParser plus token , #endOfLine asPParser token
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> makefileFailed [
	^ (#startOfLine asPParser token
		, 'Makefile:' asPParser token
		, ' failed' asPParser negate plus token
		, ' failed' asPParser token
		, #endOfLine asPParser token)
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> metacelloUnloadableClasses [
	^ (#startOfLine asPParser token
		, 'MetacelloNotification: Warning: This package depends on the following classes:' asPParser token 
		, #endOfLine asPParser negate star token 
		, #endOfLine asPParser token)
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> postgresError [

	^ postgresTimeStampParser token , ' #Error' asPParser token
	  , #endOfLine asPParser negate plus token , #endOfLine asPParser token
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> postgresTimeStampParser [
	^ #startOfLine asPParser , isoDateParser , ' ' asPParser , isoTimeParser
		, ' ' asPParser , #digit asPParser plus token , ' [P3] ' asPParser
		, #digit asPParser plus token
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> segmentationFault [
	^ 'Segmentation fault' asPParser token , #endOfLine asPParser negate star token
		, #endOfLine asPParser token
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> sendingInterruptSignalToProcess [
	^ ('Sending interrupt signal to process' asPParser token
		, #endOfLine asPParser token)
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> serverErrorText [

	^ ('server error' asPParser token)
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> shellError [
	^ (#startOfLine asPParser token
		, '/bin/sh: ' asPParser token
		, #digit asPParser plus token
		, ': ' asPParser token
		, #endOfLine asPParser negate plus token
		, #endOfLine asPParser token)
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> squareBracketAtStartOfLineError [
	^ ("#startOfLine asPParser , "'[' asPParser token
		, #digit asPParser plus , 'm' asPParser
		, #endOfLine asPParser negate star token , #endOfLine asPParser token)
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> start [
	^ brackettedError 
	/ consoleErrorSequence 
	/ coreDumped
	/ errorExpectedVersionMismatch 
	/ exceptionAccessViolationToEndOfLine
	/ exceptionIllegalInstruction 
	/ failedCommandToEndOfLine
	/ failedToDetectGTVersion 
	/ gemstoneCompilerErrors
	/ illegalInstructionToEndOfLine 
	/ vmError
	/ exitOneParser
	/ squareBracketAtStartOfLineError
	/ metacelloUnloadableClasses
	/ makeError
	/ makefileFailed
	/ shellError
	/ jenkinsError
	/ bashError
	/ postgresError
	/ anErrorText
	/ serverErrorText
	/ exceptionText
	/ exampleFailure
	/ segmentationFault
	/ hardSpace
	/ httpError
	/ errorToEndOfLine
	/ javaLangInterruptedException
	/ sendingInterruptSignalToProcess
]

{ #category : #'as yet unclassified' }
JcConsoleProblemsScanner >> vmError [
	^ #startOfLine asPParser token , 'VM Error' asPParser token
		, #endOfLine asPParser negate star token , #endOfLine asPParser token
]
