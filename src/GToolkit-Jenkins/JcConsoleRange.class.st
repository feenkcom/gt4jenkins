Class {
	#name : #JcConsoleRange,
	#superclass : #Object,
	#instVars : [
		'startPosition',
		'stopPosition',
		'logString',
		'string'
	],
	#category : #'GToolkit-Jenkins'
}

{ #category : #accessing }
JcConsoleRange >> from: anObject [ 
]

{ #category : #'as yet unclassified' }
JcConsoleRange >> gtDisplayOn: stream [
	stream nextPutAll: self string
]

{ #category : #views }
JcConsoleRange >> gtLogFor: aView [
	<gtView>
	| editor pane |
	logString ifNil: [ ^ aView empty ].
	^ aView explicit
		title: 'Log';
		stencil: [ pane := BrVerticalPane new matchParent.
			editor := BrEditor new
					aptitude: BrGlamorousCodeEditorAptitude;
					styler: JcConsoleStyler new;
					text: logString.
			editor
				scrollToPosition: (logString lineNumberCorrespondingToIndex: self startPosition).
			pane addChild: editor as: #editor.
			pane
				addAptitude: (BrGlamorousWithVerticalScrollbarAptitude new scrollableName: #editor).
			pane ]
]

{ #category : #accessing }
JcConsoleRange >> logString: log [ 
	logString := log
]

{ #category : #'as yet unclassified' }
JcConsoleRange >> startPosition [
	^ startPosition
]

{ #category : #accessing }
JcConsoleRange >> startPosition: anInteger [
	 startPosition := anInteger
]

{ #category : #'as yet unclassified' }
JcConsoleRange >> stopPosition [
	^ stopPosition
]

{ #category : #accessing }
JcConsoleRange >> stopPosition: anInteger [
	stopPosition := anInteger 
]

{ #category : #'as yet unclassified' }
JcConsoleRange >> string [
	^ string
		ifNil: [ string := logString 
				copyFrom: self startPosition 
				to: self stopPosition ]
]
