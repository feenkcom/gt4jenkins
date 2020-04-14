Class {
	#name : #JcConsoleStyler,
	#superclass : #BlTextStyler,
	#category : #'GToolkit-Jenkins'
}

{ #category : #accessing }
JcConsoleStyler >> privateStyle: aText [
	|parseResult parser executeActionParser exitOne segmentationFault newUndeclared deprecation squareBracketError |
	exitOne := #startOfLine asPParser, 'script returned exit code 1' asPParser token ==> [ :tokens | 
			(aText  
				from: tokens second start - 1
				to: tokens second stop) highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5)].
	segmentationFault := #startOfLine asPParser, 'Segmentation fault' asPParser token, #endOfLine asPParser negate star token, #endOfLine asPParser ==> [ :tokens | 
			(aText  
				from: tokens second start - 1
				to: tokens third stop) highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5)].
				
	squareBracketError := #startOfLine asPParser, '[' asPParser token, #digit asPParser plus, 'm'
 asPParser, #endOfLine asPParser negate star token, #endOfLine asPParser ==> [ :tokens | 
			(aText  
				from: tokens second start - 1
				to: tokens fifth stop) highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5)].
	newUndeclared :=  #startOfLine asPParser, 'NewUndeclaredWarning:'asPParser token, #endOfLine asPParser negate star token, #endOfLine asPParser ==> [ :tokens | 
			(aText  
				from: tokens second start - 1
				to: tokens third stop) highlight: (BrGlamorousColors failureBackgroundColor alpha: 0.5)].
	
	deprecation :=  #startOfLine asPParser, 'DeprecationPerformedNotification:' asPParser token, #endOfLine asPParser negate star token, #endOfLine asPParser ==> [ :tokens | 
			(aText  
				from: tokens second start - 1
				to: tokens third stop) highlight: (BrGlamorousColors failureBackgroundColor alpha: 0.5)].
	
	
	executeActionParser := (#startOfLine asPParser, 
		('GtRlExecuteActionSignal' asPParser / #endOfLine asPParser) negate plus token,
		('GtRlExecuteActionSignal' asPParser),
		#endOfLine asPParser negate star token,
		#endOfLine asPParser) ==> [ :tokens | 
		| color |
		color := (tokens fourth value includesSubstring: '[') 
			ifTrue: [BrGlamorousColors errorBackgroundColor alpha: 0.5]
			ifFalse: [BrGlamorousColors successBackgroundColor alpha: 0.5].
		(aText 
				from: tokens second start 
				to: tokens fourth stop) highlight: color ].
	parser := (exitOne / executeActionParser / segmentationFault / newUndeclared / deprecation / squareBracketError /
		((#startOfLine asPParser, '+' asPParser, #endOfLine asPParser negate star token , #endOfLine asPParser) ==> [ :tokens | 
			(aText  
				from: tokens third start - 1
				to: tokens third stop) highlight: BrGlamorousColors neutralBackgroundColor ])) sea star.
	parseResult := parser optimize parse: aText asString.
	^ aText
]
