Class {
	#name : #JcWfWorkflowRunStage,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsWfapi'
}

{ #category : #accessing }
JcWfWorkflowRunStage >> gtDisplayOn: stream [
	stream nextPut: (rawData at: 'name')
]
