Class {
	#name : #JcConsoleStyler,
	#superclass : #BlTextStyler,
	#category : #'GToolkit-Jenkins'
}

{ #category : #accessing }
JcConsoleStyler >> privateStyle: aText [
	|parseResult parser executeActionParser exitOne|
	exitOne := #startOfLine asPParser, 'script returned exit code 1' asPParser token ==> [ :tokens | 
			(aText  
				from: tokens second start - 1
				to: tokens second stop) highlight: (BrGlamorousColors errorBackgroundColor alpha: 0.5)].
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
	parser := (exitOne / executeActionParser /
		((#startOfLine asPParser, '+' asPParser, #endOfLine asPParser negate star token , #endOfLine asPParser) ==> [ :tokens | 
			(aText  
				from: tokens third start - 1
				to: tokens third stop) highlight: BrGlamorousColors neutralBackgroundColor ])) sea star.
	parseResult := parser parse: aText asString.
	^ aText
]
