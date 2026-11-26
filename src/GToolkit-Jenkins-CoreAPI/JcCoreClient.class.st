"
{{gtClass:JcCoreClient}} reads Jenkins core's Remote Access API. Configure the controller URL with {{gtMethod:JcCoreClient>>#baseUrl:}} and optionally a username and API token with {{gtMethod:JcCoreClient>>#username:token:}}. The client preserves controller context paths and builds JSON API URLs from path segments.
"
Class {
	#name : #JcCoreClient,
	#superclass : #Object,
	#instVars : [
		'baseUrl',
		'httpClient',
		'responseProvider'
	],
	#category : #'GToolkit-Jenkins-CoreAPI'
}

{ #category : #accessing }
JcCoreClient >> baseUrl [
	^ baseUrl
]

{ #category : #accessing }
JcCoreClient >> baseUrl: aString [
	| parsedUrl |
	parsedUrl := ZnUrl fromString: aString.
	((#(http https) includes: parsedUrl scheme)
		and: [ parsedUrl host notNil
				and: [ parsedUrl hasQuery not and: [ parsedUrl fragment isNil ] ] ])
		ifFalse: [ self
				error: 'Expected a Jenkins HTTP(S) controller URL without a query or fragment' ].
	baseUrl := parsedUrl
]

{ #category : #requests }
JcCoreClient >> getJsonAtPathSegments: pathSegments tree: aTree [
	| url json |
	url := self urlForPathSegments: pathSegments tree: aTree.
	json := responseProvider
			ifNil: [ httpClient get: url asString ]
			ifNotNil: [ responseProvider value: url ].
	^ NeoJSONReader fromString: json
]

{ #category : #'gt - views' }
JcCoreClient >> gtJobsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Jobs';
		question: 'Which jobs are available on this Jenkins controller?';
		priority: 20;
		items: [ self jobs ];
		"children: [ :each | each jobs];"
		column: 'Name' text: [ :job | job name ];
		column: 'Full name' text: [ :job | job fullName ifNil: [ job name ] ]
]

{ #category : #initialization }
JcCoreClient >> initialize [
	super initialize.
	httpClient := ZnClient new.
	httpClient enforceHttpSuccess: true.
	httpClient maximumEntitySize: 32 * 1024 * 1024
]

{ #category : #jobs }
JcCoreClient >> jobAtNames: jobNames [
	| response |
	jobNames ifEmpty: [ self error: 'A job path needs at least one name' ].
	response := self
			getJsonAtPathSegments: (self jobPathSegmentsForNames: jobNames)
			tree: 'name,fullName,url'.
	^ JcCoreJob
		client: self
		names: jobNames
		rawData: response
]

{ #category : #urls }
JcCoreClient >> jobPathSegmentsForNames: jobNames [
	| segments |
	segments := OrderedCollection new.
	jobNames
		do: [ :name | 
			segments
				add: 'job';
				add: name asString ].
	^ segments
]

{ #category : #jobs }
JcCoreClient >> jobs [
	| response |
	response := self getJsonAtPathSegments: #() tree: 'jobs[name,fullName,url]'.
	^ (response at: 'jobs' ifAbsent: [ #() ])
		collect: [ :job | 
			JcCoreJob
				client: self
				names: {job at: 'name'}
				rawData: job ]
]

{ #category : #testing }
JcCoreClient >> responseProvider: aBlock [
	responseProvider := aBlock
]

{ #category : #urls }
JcCoreClient >> urlForPathSegments: pathSegments tree: aTree [
	| url |
	baseUrl ifNil: [ self error: 'Set the Jenkins controller URL first' ].
	url := baseUrl copy.
	pathSegments do: [ :segment | url addPathSegment: segment asString ].
	url addPathSegment: 'api'.
	url addPathSegment: 'json'.
	aTree ifNotNil: [ url queryAt: 'tree' put: aTree ].
	^ url
]

{ #category : #authentication }
JcCoreClient >> username: aUsername token: aToken [
	httpClient username: aUsername password: aToken
]
