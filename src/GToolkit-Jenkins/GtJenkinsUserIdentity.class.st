Class {
	#name : #GtJenkinsUserIdentity,
	#superclass : #Object,
	#instVars : [
		'jenkinsAccount'
	],
	#classInstVars : [
		'instance'
	],
	#category : #'GToolkit-Jenkins-Login'
}

{ #category : #accessing }
GtJenkinsUserIdentity class >> instance [
	instance ifNil: [ instance := GtJenkinsUserIdentity new. instance loadSavedTokens.].
	^ instance
]

{ #category : #accessing }
GtJenkinsUserIdentity >> authTokenPreferences [
	^ self defaultPreferencesFolder / 'com.glamoroustoolkit.jenkins.v1.ston'
]

{ #category : #accessing }
GtJenkinsUserIdentity >> defaultPreferencesFolder [
	^ FileLocator preferences / 'pharo'
]

{ #category : #accessing }
GtJenkinsUserIdentity >> jenkinsAccount [
	^ jenkinsAccount
]

{ #category : #accessing }
GtJenkinsUserIdentity >> jenkinsAccount: aJenkinsAccount [
	jenkinsAccount := aJenkinsAccount
]

{ #category : #loading }
GtJenkinsUserIdentity >> jsonKey [
	^ 'com.gt.jenkins.auth'
]

{ #category : #loading }
GtJenkinsUserIdentity >> loadSavedTokens [
	| rawData authClient registeredDatabasesResponse gtJenkinsAccountJson |

	self authTokenPreferences exists ifTrue:[
	rawData := self authTokenPreferences readStreamDo: [ :aReadStream | 
		STONJSON fromStream: aReadStream].
		
	(rawData isDictionary and: [ rawData includesKey: self jsonKey ]) ifFalse: [
		^ nil ].
	gtJenkinsAccountJson := rawData at: self jsonKey.
	gtJenkinsAccountJson ifNotNil: [
		jenkinsAccount := GtJenkinsAccount new
				 		username: (gtJenkinsAccountJson at: 'username');
				 		jenkinsUrl: (gtJenkinsAccountJson at: 'jenkinsUrl');
					 	token: (gtJenkinsAccountJson at: 'token')]]
]

{ #category : #accessing }
GtJenkinsUserIdentity >> saveJsonFor: aValue into: aWriteStream [
	STONJSON 
		put: aValue 
		onStreamPretty: (ZnCharacterWriteStream on: aWriteStream encoding: 'utf8')
]

{ #category : #serialization }
GtJenkinsUserIdentity >> storeAuthTokens [
	|json|
	self defaultPreferencesFolder ensureCreateDirectory.
	json := {'schema' -> 'v1'} asDictionary.
	self jenkinsAccount  ifNotNil: [
		json at: self jsonKey put: self jenkinsAccount asDictionary].
	
	self authTokenPreferences ensureDelete;
		writeStreamDo: [ :aPreferenceStream | 
			self 
				saveJsonFor: json 
				into: aPreferenceStream ] 
	
]
