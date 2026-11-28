Trait {
	#name : #TJcCoreWebResource,
	#category : #'GToolkit-Jenkins-CoreAPI'
}

{ #category : #views }
TJcCoreWebResource >> gtWebUrlFor: aView [
	<gtView>
	^ aView textEditor
		title: 'URL';
		question: 'Where is this object in the Jenkins web interface?';
		priority: 95;
		aptitude: BrGlamorousRegularEditorAptitude;
		text: [ self webUrl ifNil: [ '' ] ];
		actionButtonIcon: BrGlamorousVectorIcons web
			tooltip: 'Open in web browser'
			action: [ :button :tab | self openInWebBrowser ]
]

{ #category : #web }
TJcCoreWebResource >> openInWebBrowser [
	^ WebBrowser openOn: self webUrl
]
