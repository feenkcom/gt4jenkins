"
{{gtClass:JcCoreClient}} reads Jenkins core's Remote Access API. Configure the controller URL with {{gtMethod:JcCoreClient>>#baseUrl:}} and optionally a username and API token with {{gtMethod:JcCoreClient>>#username:token:}}. The client preserves controller context paths and builds JSON API URLs from path segments.
"
Class {
	#name : #JcCoreClient,
	#superclass : #Object,
	#instVars : [
		'baseUrl',
		'httpClient',
		'responseProvider',
		'jobs'
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
	baseUrl := parsedUrl.
	jobs := nil
]

{ #category : #accessing }
JcCoreClient >> getAtPathSegments: pathSegments [
	| url |
	baseUrl ifNil: [ self error: 'Set the Jenkins controller URL first' ].
	url := baseUrl copy.
	pathSegments do: [ :segment | url addPathSegment: segment asString ].
	^ responseProvider
		ifNil: [ httpClient get: url asString ]
		ifNotNil: [ responseProvider value: url ]
]

{ #category : #accessing }
JcCoreClient >> getJsonAtPathSegments: pathSegments [
	| url json |
	baseUrl ifNil: [ self error: 'Set the Jenkins controller URL first' ].
	url := baseUrl copy.
	pathSegments do: [ :segment | url addPathSegment: segment asString ].
	json := responseProvider
			ifNil: [ httpClient get: url asString ]
			ifNotNil: [ responseProvider value: url ].
	^ NeoJSONReader fromString: json
]

{ #category : #accessing }
JcCoreClient >> getJsonAtPathSegments: pathSegments query: queryParameters [
	| url json |
	baseUrl ifNil: [ self error: 'Set the Jenkins controller URL first' ].
	url := baseUrl copy.
	pathSegments do: [ :segment | url addPathSegment: segment asString ].
	queryParameters keysAndValuesDo: [ :key :value | url queryAt: key put: value ].
	json := responseProvider
			ifNil: [ httpClient get: url asString ]
			ifNotNil: [ responseProvider value: url ].
	^ NeoJSONReader fromString: json
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

{ #category : #requests }
JcCoreClient >> getProgressiveTextAtPathSegments: pathSegments start: anOffset [
	| url text next |
	baseUrl ifNil: [ self error: 'Set the Jenkins controller URL first' ].
	url := baseUrl copy.
	pathSegments do: [ :segment | url addPathSegment: segment asString ].
	url queryAt: 'start' put: anOffset.
	responseProvider
		ifNil: [ text := httpClient get: url asString.
			next := httpClient response headers at: 'X-Text-Size' ifAbsent: [ nil ].
			next := next ifNotNil: [ next asInteger ] ]
		ifNotNil: [ text := responseProvider value: url ].
	text := text ifNil: [ '' ].
	^ text -> (next ifNil: [ anOffset + text utf8Encoded size ])
]

{ #category : #'gt - views' }
JcCoreClient >> gtJobsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Jobs';
		question: 'Which jobs are available on this Jenkins controller?';
		priority: 20;
		items: [ self jobs ];
		column: 'Name' text: [ :job | job name ];
		column: 'Full name' text: [ :job | job fullName ifNil: [ job name ] ];
		actionButtonIcon: BrGlamorousVectorIcons refresh
			id: #'jenkins--update-jobs'
			tooltip: 'Update jobs list from the server'
			action: [ :aButton :aTab | 
				self refreshJobs.
				aTab phlow fireViewUpdateWish ]	"children: [ :each | each jobs ];"
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

{ #category : #jobs }
JcCoreClient >> jobAtUrl: aJobUrl [
	| parsedUrl controllerSegments urlSegments jobSegments names |
	baseUrl ifNil: [ self error: 'Set the Jenkins controller URL first' ].
	parsedUrl := ZnUrl fromString: aJobUrl.
	(parsedUrl scheme = baseUrl scheme
		and: [ parsedUrl host notNil
				and: [ parsedUrl host asLowercase = baseUrl host asLowercase
						and: [ parsedUrl portOrDefault = baseUrl portOrDefault
								and: [ parsedUrl hasQuery not and: [ parsedUrl fragment isNil ] ] ] ] ])
		ifFalse: [ self error: 'Job URL must belong to the configured Jenkins controller' ].
	controllerSegments := baseUrl pathSegments asArray.
	(controllerSegments notEmpty and: [ controllerSegments last = $/ ])
		ifTrue: [ controllerSegments := controllerSegments allButLast ].
	urlSegments := parsedUrl pathSegments asArray.
	(urlSegments notEmpty and: [ urlSegments last = $/ ])
		ifTrue: [ urlSegments := urlSegments allButLast ].
	(urlSegments size >= controllerSegments size
		and: [ (urlSegments first: controllerSegments size) = controllerSegments ])
		ifFalse: [ self error: 'Job URL is outside the Jenkins controller context path' ].
	jobSegments := urlSegments allButFirst: controllerSegments size.
	(jobSegments isEmpty or: [ jobSegments size odd ])
		ifTrue: [ self error: 'Expected a Jenkins job URL with job/name segments' ].
	names := OrderedCollection new.
	1
		to: jobSegments size
		by: 2
		do: [ :index | 
			((jobSegments at: index) = 'job'
				and: [ (jobSegments at: index + 1) isString
						and: [ (jobSegments at: index + 1) isEmpty not ] ])
				ifFalse: [ self error: 'Expected a Jenkins job URL with job/name segments' ].
			names add: (jobSegments at: index + 1) ].
	^ self jobAtNames: names
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
	^ jobs ifNil: [ self refreshJobs ]
]

{ #category : #jobs }
JcCoreClient >> refreshJobs [
	| response freshJobs |
	response := self getJsonAtPathSegments: #() tree: 'jobs[name,fullName,url]'.
	freshJobs := (response at: 'jobs' ifAbsent: [ #() ])
			collect: [ :job | 
				JcCoreJob
					client: self
					names: {job at: 'name'}
					rawData: job ].
	jobs := freshJobs.
	^ jobs
]

{ #category : #testing }
JcCoreClient >> responseProvider: aBlock [
	responseProvider := aBlock.
	jobs := nil
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
	httpClient username: aUsername password: aToken.
	jobs := nil
]
