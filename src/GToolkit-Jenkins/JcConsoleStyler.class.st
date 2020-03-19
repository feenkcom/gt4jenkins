Class {
	#name : #JcConsoleStyler,
	#superclass : #BlTextStyler,
	#category : #'GToolkit-Jenkins'
}

{ #category : #accessing }
JcConsoleStyler >> privateStyle: aText [
	|parseResult parser|
	parser := (('AssertionFailure' asPParser token ==> [ :token | 
			(aText 
				from: token start 
				to: token stop) highlight: BrGlamorousColors errorBackgroundColor ]) / 
		((#startOfLine asPParser, '+' asPParser, #endOfLine asPParser negate star token , #endOfLine asPParser) ==> [ :tokens | 
			(aText  
				from: tokens third start - 1
				to: tokens third stop) highlight: BrGlamorousColors textHighlightColor ])) sea star.
	parseResult := parser parse: aText asString.
	^ aText
	 
]
