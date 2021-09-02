Class {
	#name : 'JcPipelineStep',
	#superclass : 'JcModelElement',
	#category : 'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanRestImplPipeline'
}

{ #category : 'accessing' }
JcPipelineStep >> getLogText [
	|text logURL|
	logURL := ((((rawData at:'actions') detect: ([:a | (a at:'urlName') = 'log'])) at: '_links') at: 'self') at: 'href'.
	text := (super urlClientFor: logURL) getRawData.
	text ifNil: [^nil].
	text := text copyReplaceAll: (Character value:27) asString with: ''.
	^ text
]

{ #category : 'accessing' }
JcPipelineStep >> gtDisplayOn: stream [
	|displayDescription|
	displayDescription := (rawData at: 'displayDescription').
	displayDescription ifNil: [stream nextPutAll: (rawData at: 'displayName')].
	displayDescription ifNotNil: [stream nextPutAll: ('', displayDescription  )]
]

{ #category : 'accessing' }
JcPipelineStep >> gtLogFor: aView [
	<gtView>
	|text logURL|
	text := self getLogText.
	text ifNil: [^aView empty].
	^ aView textEditor
		aptitude: BrGlamorousCodeEditorAptitude;
		styler: JcConsoleStyler new;
		title: 'Console Log';
		text: [text]
]

{ #category : 'accessing' }
JcPipelineStep >> result [
	^ rawData at: 'result'
]

{ #category : 'accessing' }
JcPipelineStep >> resultBackgroundColor [
	^ JcJenkinsClient backgroundColorForStatus: self result
]
