Class {
	#name : #BaselineOfGToolkit4Jenkins,
	#superclass : #BaselineOf,
	#category : #BaselineOfGToolkit4Jenkins
}

{ #category : #baseline }
BaselineOfGToolkit4Jenkins >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec
				baseline: 'NeoJSON'
				with: [ spec repository: 'github://svenvc/NeoJSON:master/repository' ].

			spec
				package: 'GToolkit-Jenkins';
				package: 'GToolkit-Jenkins-CoreAPI' with: [ spec requires: #('NeoJSON') ] ]
]
