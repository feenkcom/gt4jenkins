Class {
	#name : 'JcJenkinsClient',
	#superclass : 'Object',
	#instVars : [
		'znclient',
		'url',
		'username',
		'password'
	],
	#category : 'GToolkit-Jenkins'
}

{ #category : 'constants' }
JcJenkinsClient class >> backgroundColorForStatus: aString [
	aString = 'SUCCESS' ifTrue: [^ BrGlamorousColors successBackgroundColor].
	aString = 'FAILURE' ifTrue: [^ BrGlamorousColors errorBackgroundColor].
	aString = 'FAILED' ifTrue: [^ BrGlamorousColors errorBackgroundColor].
	aString = 'UNSTABLE' ifTrue: [^ BrGlamorousColors failureBackgroundColor ].
	^ BrGlamorousColors lightBorderColor.
]

{ #category : 'constants' }
JcJenkinsClient class >> backgroundColorForTestStatus: aString [
	aString = 'PASSED' ifTrue: [^ BrGlamorousColors successBackgroundColor].
	aString = 'FAILED' ifTrue: [^ BrGlamorousColors failureBackgroundColor].
	^ BrGlamorousColors lightBorderColor.
]

{ #category : 'accessing' }
JcJenkinsClient >> blueOcean [
	|json modelBuilder model|
	self setupJwtToken.
	json := znclient get: self blueOceanUrl.
	modelBuilder := JcModelBuilder new.
	modelBuilder jenkinsClient: self.
	model := modelBuilder modelFrom: (NeoJSONReader fromString: json).
	^ model.
]

{ #category : 'accessing' }
JcJenkinsClient >> blueOceanUrl [
	|result|
	result := self url.
	^ (result findString:'/blue/rest/organizations/jenkins') > 0 
		ifTrue:[ result ]
		ifFalse: [result,'/blue/rest/organizations/jenkins']
	
]

{ #category : 'accessing' }
JcJenkinsClient >> getRootOfUrl [
	^ url asUrl scheme, '://', url asUrl host.
]

{ #category : 'accessing' }
JcJenkinsClient >> hasValidUrl [
	url asUrl ifNil: [ ^ false ].
	url asUrl scheme ifNil: [ ^ false ].
	url asUrl host ifNil: [ ^ false ].
	^ true
]

{ #category : 'accessing' }
JcJenkinsClient >> password [
	^ password
]

{ #category : 'accessing' }
JcJenkinsClient >> plainJenkinsApi [
	| modelBuilder model jobs|
	modelBuilder := JcModelBuilder new.
	jobs := znclient get: ('' join: { url . '/api/json?tree=jobs[name,jobs[name,jobs[name,builds[id,result,timestamp,url]]]]&pretty=true'}).
	modelBuilder jenkinsClient: self.
	model := modelBuilder modelFrom: (NeoJSONReader fromString: jobs).
	^ model.
]

{ #category : 'accessing' }
JcJenkinsClient >> setBasicAuth [
	znclient := ZnClient new
	username: username password: password.
]

{ #category : 'accessing' }
JcJenkinsClient >> setupJwtToken [
	| jwt rootUrl|
	rootUrl := self getRootOfUrl.
	znclient get: ('' join: { rootUrl .'/jwt-auth/token?maxExpiryTimeInMins=120'}).
	jwt := znclient response headers at:'X-Blueocean-Jwt'.
	znclient request headers removeKey: 'Authorization' ifAbsent: [].
	znclient request setAuthorization: 'Bearer ', jwt.
]

{ #category : 'accessing' }
JcJenkinsClient >> url [
	^ url
]

{ #category : 'accessing' }
JcJenkinsClient >> username [
	^ username
]

{ #category : 'accessing' }
JcJenkinsClient >> username: anUsername token: aToken url: anUrl [
	znclient := ZnClient new
	username: anUsername password: aToken.
	username := anUsername.
	password := aToken.
	url := anUrl.
]

{ #category : 'accessing' }
JcJenkinsClient >> znclient [
	^ znclient
]
