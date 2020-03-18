Class {
	#name : #JcConsoleStyler,
	#superclass : #BlTextStyler,
	#category : #'GToolkit-Jenkins'
}

{ #category : #accessing }
JcConsoleStyler >> privateStyle: aText [
	|parseResult parser|
	parser := (('AssertionFailure' asPParser token ==> [ :token | 
			aText attributes: { BlTextForegroundAttribute new paint: Color red } 
				from: token start 
				to: token stop ]) / 
		((#startOfLine asPParser, '+' asPParser, #endOfLine asPParser negate star token , #endOfLine asPParser) ==> [ :tokens | 
			aText attributes: {
					BlTextForegroundAttribute new paint: Color blue } 
				from: tokens third start - 1
				to: tokens third stop ])) sea star.
	parseResult := parser parse: aText asString.
	^ aText
	 
]
