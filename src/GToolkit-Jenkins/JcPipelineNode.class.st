Class {
	#name : #JcPipelineNode,
	#superclass : #JcModelElement,
	#instVars : [
		'parentRun'
	],
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanRestImplPipeline'
}

{ #category : #accessing }
JcPipelineNode >> gtDisplayOn: stream [
	stream nextPutAll: (self name)
]

{ #category : #accessing }
JcPipelineNode >> name [
	^ rawData at: 'displayName'
]

{ #category : #accessing }
JcPipelineNode >> parentRun [
	^ parentRun
]

{ #category : #accessing }
JcPipelineNode >> parentRun: aParentRun [
	parentRun := aParentRun
]

{ #category : #accessing }
JcPipelineNode >> result [
	^ rawData at: 'result'
]

{ #category : #accessing }
JcPipelineNode >> resultBackgroundColor [
	^ JcJenkinsClient backgroundColorForStatus: self result
]
