Class {
	#name : #GtJenkinsAccount,
	#superclass : #Object,
	#instVars : [
		'username',
		'token',
		'jenkinsUrl'
	],
	#category : #'GToolkit-Jenkins-Login'
}

{ #category : #accessing }
GtJenkinsAccount >> asDictionary [
	^ {'username' -> self username .
	   'token' -> self token.
	   'jenkinsUrl' -> self jenkinsUrl} asDictionary
]

{ #category : #accessing }
GtJenkinsAccount >> jenkinsUrl [
	^ jenkinsUrl
]

{ #category : #converting }
GtJenkinsAccount >> jenkinsUrl: aJenkinsUrl [
	 jenkinsUrl := aJenkinsUrl
]

{ #category : #accessing }
GtJenkinsAccount >> token [
	^ token
]

{ #category : #accessing }
GtJenkinsAccount >> token: aToken [
	token := aToken
]

{ #category : #accessing }
GtJenkinsAccount >> username [
	^ username
]

{ #category : #accessing }
GtJenkinsAccount >> username: anUsernname [
	username := anUsernname
]
