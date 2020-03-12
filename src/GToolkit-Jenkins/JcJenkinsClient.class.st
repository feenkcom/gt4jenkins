Class {
	#name : #JcJenkinsClient,
	#superclass : #Object,
	#instVars : [
		'znclient',
		'url',
		'username',
		'password'
	],
	#category : #'GToolkit-Jenkins'
}

{ #category : #constants }
JcJenkinsClient class >> backgroundColorForStatus: aString [
	aString = 'SUCCESS' ifTrue: [^ BrGlamorousColors successBackgroundColor].
	aString = 'FAILURE' ifTrue: [^ BrGlamorousColors errorBackgroundColor].
	aString = 'UNSTABLE' ifTrue: [^ BrGlamorousColors failureBackgroundColor ].
	^ BrGlamorousColors lightBorderColor.
]

{ #category : #constants }
JcJenkinsClient class >> backgroundColorForTestStatus: aString [
	aString = 'PASSED' ifTrue: [^ BrGlamorousColors successBackgroundColor].
	aString = 'FAILED' ifTrue: [^ BrGlamorousColors failureBackgroundColor].
	^ BrGlamorousColors lightBorderColor.
]

{ #category : #accessing }
JcJenkinsClient >> blueOcean [
	|json modelBuilder model|
	self setupJwtToken.
	json := znclient get: ('' join:{url .'/blue/rest/organizations'}).
	modelBuilder := JcModelBuilder new.
	modelBuilder jenkinsClient: self.
	model := modelBuilder modelFrom: (NeoJSONReader fromString: json).
	^ model.
]

{ #category : #accessing }
JcJenkinsClient >> password [
	^ password
]

{ #category : #accessing }
JcJenkinsClient >> setupJwtToken [
	| jwt |
	znclient get: ('' join: { url .'/jwt-auth/token?maxExpiryTimeInMins=120'}).
	jwt := znclient response headers at:'X-Blueocean-Jwt'.
	znclient request headers removeKey: 'Authorization' ifAbsent: [].
	znclient request setAuthorization: 'Bearer ', jwt.
]

{ #category : #accessing }
JcJenkinsClient >> url [
	^ url
]

{ #category : #accessing }
JcJenkinsClient >> username [
	^ username
]

{ #category : #accessing }
JcJenkinsClient >> username: anUsername token: aToken url: anUrl [
	znclient := ZnClient new
	username: anUsername password: aToken.
	username := anUsername.
	password := aToken.
	url := anUrl.
]

{ #category : #accessing }
JcJenkinsClient >> znclient [
	^ znclient
]
