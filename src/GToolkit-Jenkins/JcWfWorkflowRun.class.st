Class {
	#name : #JcWfWorkflowRun,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsWfapi'
}

{ #category : #accessing }
JcWfWorkflowRun >> stages [
	^ super modelBuilder modelFrom: (rawData at: 'stages') className:'IoJenkinsWfapi.WfWorkflowRunStage'.
]
