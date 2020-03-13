Class {
	#name : #JcPipelineStep,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanRestImplPipeline'
}

{ #category : #accessing }
JcPipelineStep >> gtDisplayOn: stream [
	|displayDescription|
	displayDescription := (rawData at: 'displayDescription').
	displayDescription ifNil: [stream nextPutAll: (rawData at: 'displayName')].
	displayDescription ifNotNil: [stream nextPutAll: ('', displayDescription  )]
]

{ #category : #accessing }
JcPipelineStep >> gtLogFor: aView [
	<gtView>
	|text logURL|
	logURL := ((((rawData at:'actions') detect: ([:a | (a at:'urlName') = 'log'])) at: '_links') at: 'self') at: 'href'.
	text := (super urlClientFor: logURL) getRawData.
	text ifNil: [^aView empty].
	^ aView textEditor
		look: BrGlamorousCodeEditorLook;
		title: 'Console Log';
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
