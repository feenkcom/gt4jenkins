Class {
	#name : #JcConsoleStylerExamples,
	#superclass : #Object,
	#category : #'GToolkit-Jenkins-Examples'
}

{ #category : #accessing }
JcConsoleStylerExamples >> postgresError [
	<gtExample>
	<return: #BlRunRopedText>
	| aText |
	aText := '2021-09-18 14:16:14 115 [P3] 4529 #Query CREATE TABLE ...
2021-09-18 14:16:14 116 [P3] 4529 #Error P3Notification PostgreSQL relation "relation_name" already exists, skipping
2021-09-18 14:16:14 117 [P3] 4529 #Result CREATE TABLE, 20 ms
2021-09-18 14:16:14 118 [P3] 4529 #Close' asRopedText.
	^ self
		style: aText
		attributeClass: BlTextHighlightAttribute
		from: 59
		to: 174
]

{ #category : #accessing }
JcConsoleStylerExamples >> postgresNeutralLog [
	<gtExample>
	<return: #BlRunRopedText>
	| aText |
	aText := '2021-09-18 14:16:20 236 [P3] 4565 #Connect psql://postgres@localhost:5432/database_name MD5Password
2021-09-18 14:16:20 237 [P3] 4565 #Query CREATE TABLE IF NOT EXISTS table_name ( 	    		user_id	uuid PRIMARY KEY,     			name	text NOT NULL,     			created_at timestamp DEFAULT current_timestamp NOT NULL)
2021-09-18 14:16:20 238 [P3] 4565 #Error P3Notification PostgreSQL relation "table_name" already exists, skipping
2021-09-18 14:16:20 239 [P3] 4565 #Result CREATE TABLE, 20 ms
2021-09-18 14:16:20 240 [P3] 4565 #Close
' asRopedText.
	^ self
		style: aText
		attributeClass: BlTextForegroundAttribute
		from: 101
		to: 304
]

{ #category : #accessing }
JcConsoleStylerExamples >> segmentationFault [

	<gtExample>
	<noTest>
	"still need to investigate why this does not work"
	| aText |
	aText := '2021-09-18 14:16:23 321 [P3] 4582 #CloseSegmentation fault (core dumped)
script returned exit code 139
' asRopedText.
	^ self
		  style: aText
		  attributeClass: BlTextHighlightAttribute
		  from: 41
		  to: 72
]

{ #category : #accessing }
JcConsoleStylerExamples >> style: aText attributeClass: anAttributeClass from: aStart to: aStop [

	<gtExample>
	| aStyledText theStartAttributes |
	aStyledText := self styler style: aText.
	self assert: aText == aStyledText.

	theStartAttributes := aStyledText attributesAt: aStart.
	self assert: theStartAttributes isNotEmpty description: [ 
		'Start attributes is empty instead of having the '
		, anAttributeClass name , ' attribute' ].
	self
		assert: (theStartAttributes anySatisfy: [ :eachAttribute | 
				 eachAttribute class = anAttributeClass ])
		description: [ 
			'Start attributes does not include the ' , anAttributeClass name
			, ' attribute' ].

	theStartAttributes := aStyledText attributesAt: aStop.
	self assert: theStartAttributes isNotEmpty description: [ 
		'Stop attributes is empty instead of having the '
		, anAttributeClass name , ' attribute' ].
	self
		assert: (theStartAttributes anySatisfy: [ :eachAttribute | 
				 eachAttribute class = anAttributeClass ])
		description: [ 
			'Stop attributes does not include the ' , anAttributeClass name
			, ' attribute' ].

	^ aStyledText
]

{ #category : #accessing }
JcConsoleStylerExamples >> styler [
	<gtExample>
	<return: #JcConsoleStyler>
	^ JcConsoleStyler new
]
