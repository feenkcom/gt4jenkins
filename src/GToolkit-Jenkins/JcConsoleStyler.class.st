Class {
	#name : #JcConsoleStyler,
	#superclass : #BlTextStyler,
	#category : #'GToolkit-Jenkins'
}

{ #category : #accessing }
JcConsoleStyler >> parser [
	^'AssertionFailure' asPParser sea.
]

{ #category : #accessing }
JcConsoleStyler >> privateStyle: aText [
	|parseResult|
	parseResult := self parser parse: aText.
	parseResult isCollection ifTrue: [
	parseResult second isString ifTrue: [
		|start stop|
		start := parseResult first size + 1.
		stop := start + parseResult second size -1.
		aText attributes: {
					BlTextForegroundAttribute new paint: Color red } 
				from: start 
				to: stop.
	]].
	^ aText
	 
]
