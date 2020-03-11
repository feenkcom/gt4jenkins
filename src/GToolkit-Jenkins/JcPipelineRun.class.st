Class {
	#name : #JcPipelineRun,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanRestImplPipeline'
}

{ #category : #accessing }
JcPipelineRun >> duration [
	^ (json at: 'durationInMillis')  asNumber milliSeconds
]

{ #category : #accessing }
JcPipelineRun >> gtDisplayOn: stream [
	stream nextPutAll: (json at: 'id')
]

{ #category : #accessing }
JcPipelineRun >> nodes [
	^ (super linksClientFor: 'nodes') execute
]

{ #category : #accessing }
JcPipelineRun >> result [
	^ json at: 'result'
]

{ #category : #accessing }
JcPipelineRun >> resultBackgroundColor [
	^ JcJenkinsClient backgroundColorForStatus: self result
]

{ #category : #accessing }
JcPipelineRun >> startTime [
	^ DateAndTime fromString: (json at: 'startTime')
]
