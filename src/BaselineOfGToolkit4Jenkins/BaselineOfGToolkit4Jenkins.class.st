Class {
	#name : #BaselineOfGToolkit4Jenkins,
	#superclass : #BaselineOf,
	#category : #BaselineOfGToolkit4Jenkins
}

{ #category : #baseline }
BaselineOfGToolkit4Jenkins >> baseline: spec [
	<baseline>
	spec for: #'common' do: [
		spec
			baseline: 'NeoJSON' with: [
				spec repository: 'github://svenvc/NeoJSON:11e274dd96dc9636cab90929937b7cd09719de7c/repository' ].

		spec package: 'GToolkit-Jenkins'.
		spec package: 'GToolkit-Jenkins-CoreAPI' with: [
			spec requires: #(#NeoJSON) ].
	]
]
