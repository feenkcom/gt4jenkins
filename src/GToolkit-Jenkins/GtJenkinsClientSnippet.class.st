Class {
	#name : #GtJenkinsClientSnippet,
	#superclass : #GtSnippet,
	#instVars : [
		'url',
		'user',
		'token'
	],
	#category : #'GToolkit-Jenkins'
}

{ #category : #accessing }
GtJenkinsClientSnippet class >> typeName [
	<return: #String>

	^ 'jenkins'
]

{ #category : #'json mapping' }
GtJenkinsClientSnippet class >> xdocSnippetMappingFor: aNeoJSONMapper [
	"ignore"
]

{ #category : #converting }
GtJenkinsClientSnippet >> asElement [
	| snippetContainer formElement urlInputElement tokenInputElement toolbar playInspectButton playBlueInspectButton userInputElement anExpanderElement jenkinsAccount |
	formElement := BlElement new.
	
	formElement constraintsDo: [ :c |  
		c vertical fitContent.
		c horizontal matchParent ].
	formElement layout: (BlGridLayout horizontal columnCount: 2; cellSpacing: 10).

	urlInputElement := self inputElementNamed: 'Url' in: formElement.
	
	userInputElement := self inputElementNamed: 'User' in: formElement.
	tokenInputElement := self inputElementNamed: 'Token' in: formElement.
	tokenInputElement editor text replacingText: $*.
	
	jenkinsAccount := GtJenkinsUserIdentity instance jenkinsAccount.
	jenkinsAccount ifNotNil:[
		userInputElement text: (jenkinsAccount username).
		urlInputElement text: (jenkinsAccount jenkinsUrl).
		tokenInputElement text: (jenkinsAccount token ).
		tokenInputElement editor text replacingText: $*.
	].

	toolbar := BrToolbar new
		look: BrToolbarLook new;
		layout: (BlGridLayout horizontal rowCount: 1; cellSpacing: 10);
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ].
	playInspectButton := BrButton new.
	playInspectButton 
		beSmallSize;
		look: BrGlamorousButtonWithIconLook;
		label: 'Inspect connection';
		icon: BrGlamorousVectorIcons playinspect;
		action: [ 
			| client username tokenString urlString |
			username := userInputElement editor text asString.
			tokenString := tokenInputElement editor text asString.
			urlString := urlInputElement editor text asString.
			self storeJenkinsAccountToPreferencesFolderWith: username 
				token: tokenString 
				andUrl:urlString.
			client := JcJenkinsClient new
				username: username
				token: tokenString
				url: urlInputElement editor text asString.
			[ playInspectButton phlow spawnObject: client blueOcean ]
				on: KeyNotFound 
					do:[playInspectButton phlow spawnObject: client plainJenkinsApi]].
			
	toolbar addItem: playInspectButton.
	
	
	snippetContainer := BrVerticalPane new
		vFitContent;
		hMatchParent.
	snippetContainer addChild: formElement.
	snippetContainer addChild: toolbar.
	
	anExpanderElement := BrExpander new
		vFitContent;
		hMatchParent;
		expand;
		look: GtCoderExpanderLook new recreateHeader;
		header: [ BrLabel new
			look: (BrGlamorousLabelLook new glamorousCodeFontAndSize foreground: BrGlamorousColors disabledButtonTextColor);
			text: ('Jenkins: ', userInputElement editor text asString, '@',urlInputElement editor text asString) ];
		content: [ snippetContainer ].
	
	
	^ BrFrame new
		vFitContent;
		hMatchParent;
		look: (GtSnippetContainerLook new snippet: self);
		addChild: anExpanderElement
]

{ #category : #converting }
GtJenkinsClientSnippet >> asStencilBuilder [
	^ self
]

{ #category : #converting }
GtJenkinsClientSnippet >> bind: aSnippet to: aSnippetElement [
]

{ #category : #converting }
GtJenkinsClientSnippet >> inputElementNamed: aString in: formElement [
	| labelElement inputElement text |
	labelElement := BrLabel new text: aString, ':'; look: BrGlamorousLabelLook.
	labelElement constraintsDo: [ :c | 
		c vertical fitContent.
		c horizontal fitContent.
		c grid vertical alignCenter ].
	
	inputElement := BrEditor new
				hMatchParent;
				vFitContentLimited;
				look: BrGlamorousInputFieldSpacingLook new + BrGlamorousRegularEditorLook new;
				text: ''.
	
	formElement addChild: labelElement.
	formElement addChild: inputElement.
	^ inputElement
]

{ #category : #converting }
GtJenkinsClientSnippet >> storeJenkinsAccountToPreferencesFolderWith: username token: tokenString andUrl: aJenkinsUrl [
	GtJenkinsUserIdentity instance 
		jenkinsAccount: (GtJenkinsAccount new 
			username:username; 
			token: tokenString;
			jenkinsUrl: aJenkinsUrl).
	GtJenkinsUserIdentity instance storeAuthTokens.
]

{ #category : #accessing }
GtJenkinsClientSnippet >> string [
	<return: #String>
	^ String streamContents: [ :aStream | 
		aStream nextPutAll: 'Jenkins:'.
		self url ifNotNil: [ aStream space; print: self url ].
		self user ifNotNil: [ aStream space; print: self user ]. ]
]

{ #category : #accessing }
GtJenkinsClientSnippet >> text [
	<return: #BlRope>
	^ self string asRopedText
]

{ #category : #accessing }
GtJenkinsClientSnippet >> token [
	^ token
]

{ #category : #accessing }
GtJenkinsClientSnippet >> token: anObject [
	token := anObject
]

{ #category : #accessing }
GtJenkinsClientSnippet >> url [
	^ url
]

{ #category : #accessing }
GtJenkinsClientSnippet >> url: anObject [
	url := anObject
]

{ #category : #accessing }
GtJenkinsClientSnippet >> user [
	^ user
]

{ #category : #accessing }
GtJenkinsClientSnippet >> user: anObject [
	user := anObject
]
