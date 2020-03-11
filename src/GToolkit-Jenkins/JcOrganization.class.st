Class {
	#name : #JcOrganization,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanServiceEmbeddedRest'
}

{ #category : #accessing }
JcOrganization >> pipelines [
	^ (super linksClientFor: 'pipelines') execute
]
