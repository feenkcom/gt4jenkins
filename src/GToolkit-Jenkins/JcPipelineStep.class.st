Class {
	#name : #JcPipelineStep,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanRestImplPipeline'
}

{ #category : #accessing }
JcPipelineStep >> getLogText [
	|text logURL|
	logURL := ((((rawData at:'actions') detect: ([:a | (a at:'urlName') = 'log'])) at: '_links') at: 'self') at: 'href'.
	(logURL includesSubstring: 'start=')
		ifFalse: [ 
			logURL := logURL allButLast, '?start=0' ].
	text := (super urlClientFor: logURL) getRawData.
	text ifNil: [^nil].
	text := text copyReplaceAll: (Character value:27) asString with: ''.
	^ text
]

{ #category : #accessing }
JcPipelineStep >> gtActionParseClonerLogFor: anAction [
	<gtAction>
	| displayDescription |
	
	rawData ifNil: [ ^ anAction noAction ].
	displayDescription := (rawData at: 'displayDescription').
	displayDescription ifNil: [ ^ anAction noAction ].
	(displayDescription includesSubstring: 'gt-releaser run-releaser') ifFalse: [
		^ anAction noAction ].
	
	^ anAction button
		tooltip: 'Parse releaser logs';
		priority: 11;
		icon: BrGlamorousVectorIcons playinspect;
		action: [ :aButton | 
			aButton phlow spawnObject: (GtRlReleaserSignalsLogReader 
				readFrom:  self getLogText readStream) ]
]

{ #category : #accessing }
JcPipelineStep >> gtDisplayOn: stream [
	|displayDescription|
	displayDescription := (rawData at: 'displayDescription').
	displayDescription ifNil: [stream nextPutAll: (rawData at: 'displayName')].
	displayDescription ifNotNil: [stream nextPutAll: ('', displayDescription  )]
]

{ #category : #accessing }
JcPipelineStep >> gtInstructionsFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Instructions';
		aptitude: BrGlamorousCodeEditorAptitude;
		text: [ self gtDisplayString ]
]

{ #category : #accessing }
JcPipelineStep >> gtLogFor: aView [
	<gtView>
	|text|
	text := self getLogText.
	text ifNil: [^aView empty].
	^ aView textEditor
		aptitude: BrGlamorousCodeEditorAptitude;
		styler: JcConsoleStyler new;
		title: 'Console log';
		text: [text]
]

{ #category : #accessing }
JcPipelineStep >> result [
	^ rawData at: 'result'
]

{ #category : #accessing }
JcPipelineStep >> resultBackgroundColor [
	^ JcJenkinsClient backgroundColorForStatus: self result
]
