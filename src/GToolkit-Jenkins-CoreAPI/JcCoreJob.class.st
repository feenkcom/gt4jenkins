"
{{gtClass:JcCoreJob}} represents a Jenkins job or folder. It retains the response data and its path within a {{gtClass:JcCoreClient}} so nested jobs and build summaries can be requested on demand.
"
Class {
	#name : #JcCoreJob,
	#superclass : #Object,
	#instVars : [
		'client',
		'names',
		'rawData',
		'jobs',
		'builds'
	],
	#category : #'GToolkit-Jenkins-CoreAPI'
}

{ #category : #'instance creation' }
JcCoreJob class >> client: aClient names: jobNames rawData: aDictionary [
	^ self new
		client: aClient
		names: jobNames
		rawData: aDictionary
]

{ #category : #builds }
JcCoreJob >> builds [
	^ builds ifNil: [ self refreshBuilds ]
]

{ #category : #initialization }
JcCoreJob >> client: aClient names: jobNames rawData: aDictionary [
	client := aClient.
	names := jobNames asArray.
	rawData := aDictionary.
	jobs := nil.
	builds := nil.
	^ self
]

{ #category : #accessing }
JcCoreJob >> fullName [
	^ rawData at: 'fullName' ifAbsent: [ nil ]
]

{ #category : #'gt - views' }
JcCoreJob >> gtBuildsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Builds';
		question: 'Which builds belong to this Jenkins job?';
		priority: 20;
		items: [ self builds ];
		column: 'Number' text: [ :run | run number asString ];
		column: 'URL' text: [ :run | run url ifNil: [ '' ] ] weight: 8;
		actionButtonIcon: BrGlamorousVectorIcons refresh
			id: #'jenkins--update-builds'
			tooltip: 'Update builds list from the server'
			action: [ :aButton :aTab | 
				self refreshBuilds.
				aTab phlow fireViewUpdateWish ]
]

{ #category : #printing }
JcCoreJob >> gtDisplayOn: aStream [
	aStream nextPutAll: (self fullName ifNil: [ self name ])
]

{ #category : #'gt - views' }
JcCoreJob >> gtJobsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Jobs';
		question: 'Which jobs are inside this Jenkins folder?';
		priority: 30;
		items: [ self jobs ];
		column: 'Name' text: [ :job | job name ];
		column: 'Full name' text: [ :job | job fullName ifNil: [ job name ] ];
		actionButtonIcon: BrGlamorousVectorIcons refresh
			id: #'jenkins--update-jobs'
			tooltip: 'Update jobs list from the server'
			action: [ :aButton :aTab | 
				self refreshJobs.
				aTab phlow fireViewUpdateWish ]
]

{ #category : #'gt - views' }
JcCoreJob >> gtRawDataFor: aView [
	<gtView>
	^ aView forward
		title: 'Raw data';
		question: 'What JSON data created this Jenkins job?';
		priority: 90;
		object: [ self rawData ];
		view: #gtTreeFor:context:
]

{ #category : #jobs }
JcCoreJob >> jobs [
	^ jobs ifNil: [ self refreshJobs ]
]

{ #category : #accessing }
JcCoreJob >> name [
	^ rawData at: 'name' ifAbsent: [ names last ]
]

{ #category : #accessing }
JcCoreJob >> names [
	^ names
]

{ #category : #accessing }
JcCoreJob >> rawData [
	^ rawData
]

{ #category : #builds }
JcCoreJob >> refreshBuilds [
	| response freshBuilds |
	response := client
			getJsonAtPathSegments: (client jobPathSegmentsForNames: names)
			tree: 'builds[number,url]'.
	freshBuilds := (response at: 'builds' ifAbsent: [ #() ])
			collect: [ :build | 
				JcCoreRun
					client: client
					jobNames: names
					rawData: build ].
	builds := freshBuilds.
	^ builds
]

{ #category : #jobs }
JcCoreJob >> refreshJobs [
	| response freshJobs |
	response := client
			getJsonAtPathSegments: (client jobPathSegmentsForNames: names)
			tree: 'jobs[name,fullName,url]'.
	freshJobs := (response at: 'jobs' ifAbsent: [ #() ])
			collect: [ :job | 
				JcCoreJob
					client: client
					names: (names copyWith: (job at: 'name'))
					rawData: job ].
	jobs := freshJobs.
	^ jobs
]

{ #category : #accessing }
JcCoreJob >> url [
	^ rawData at: 'url' ifAbsent: [ nil ]
]
