Class {
	#name : #JcPipelineNode,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanRestImplPipeline'
}

{ #category : #accessing }
JcPipelineNode >> gtDisplayOn: stream [
	stream nextPutAll: (self name)
]

{ #category : #accessing }
JcPipelineNode >> name [
	^ json at: 'displayName'
]
