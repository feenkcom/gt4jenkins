Class {
	#name : #JcWfWorkflowRunStage,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsWfapi'
}

{ #category : #accessing }
JcWfWorkflowRunStage >> gtDisplayOn: stream [
	stream nextPutAll: (rawData at: 'name')
]

{ #category : #accessing }
JcWfWorkflowRunStage >> result [
	^ rawData at: 'status'
]

{ #category : #accessing }
JcWfWorkflowRunStage >> resultBackgroundColor [
	^ JcJenkinsClient backgroundColorForResult: self result
]
