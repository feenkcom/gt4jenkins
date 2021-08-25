Class {
	#name : 'JcFreeStyleProject',
	#superclass : 'JcModelElement',
	#category : 'GToolkit-Jenkins-Generated-HudsonModel'
}

{ #category : 'accessing' }
JcFreeStyleProject >> gtDisplayOn: stream [
	stream nextPutAll: (rawData at: 'name')
]
