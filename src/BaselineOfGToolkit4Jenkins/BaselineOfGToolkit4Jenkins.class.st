Class {
	#name : #BaselineOfGToolkit4Jenkins,
	#superclass : #BaselineOf,
	#category : #BaselineOfGToolkit4Jenkins
}

{ #category : #baseline }
BaselineOfGToolkit4Jenkins >> baseline: spec [
	<baseline>
	spec
		for: #common do: [
			spec
				package: 'GToolkit-Jenkins' ]
]
