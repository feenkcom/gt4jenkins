"
{{gtClass:JcCoreJob}} represents a Jenkins job or folder. It retains the response data and its path within a {{gtClass:JcCoreClient}} so nested jobs and build summaries can be requested on demand.
"
Class {
	#name : #JcCoreJob,
	#superclass : #Object,
	#traits : 'TJcCoreWebResource',
	#classTraits : 'TJcCoreWebResource classTrait',
	#instVars : [
		'client',
		'names',
		'rawData',
		'jobs',
		'builds',
		'queuedRuns'
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

{ #category : #testing }
JcCoreJob class >> isRunIdentifier: aString [
	^ (aString isString
		and: [ aString notEmpty and: [ aString allSatisfy: #isDigit ] ])
		or: [ #('lastBuild' 'lastCompletedBuild' 'lastFailedBuild' 'lastStableBuild' 'lastSuccessfulBuild' 'lastUnstableBuild' 'lastUnsuccessfulBuild')
				includes: aString ]
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
	queuedRuns := nil.
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
		items: [ self queuedRuns , self builds ];
		column: 'Status'
			icon: [ :run | run statusIcon ]
			width: 50;
		column: 'Result'
			text: [ :run | run resultText ]
			width: 70;
		column: 'Item'
			text: [ :run | run gtDisplayText ]
			width: 50;
		column: 'Duration'
			text: [ :run | run durationText ]
			width: 200;
		column: 'Start time' text: [ :run | run startTimeText ];
		actionButtonIcon: BrGlamorousVectorIcons refresh
			id: #'jenkins--update-builds'
			tooltip: 'Update builds list from the server'
			action: [ :aButton :aTab | 
				self refreshBuilds.
				self refreshQueuedRuns.
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

{ #category : #queue }
JcCoreJob >> queuedRuns [
	^ queuedRuns ifNil: [ self refreshQueuedRuns ]
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
			tree: 'builds[number,url,result,building,duration,timestamp]'.
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

{ #category : #queue }
JcCoreJob >> refreshQueuedRuns [
	| response items number |
	response := [ client
			getJsonAtPathSegments: #('queue' 'api' 'json')
			tree: 'items[id,inQueueSince,why,task[url]]' ]
			on: ZnHttpUnsuccessful
			do: [ :error | Dictionary new ].
	items := ((response at: 'items' ifAbsent: [ #() ])
			select: [ :each | 
				((each at: 'task' ifAbsent: [ Dictionary new ]) at: 'url' ifAbsent: [ nil ])
					= self url ])
			sorted: [ :a :b | (a at: 'inQueueSince' ifAbsent: [ 0 ]) <= (b at: 'inQueueSince' ifAbsent: [ 0 ]) ].
	number := self builds isEmpty
			ifTrue: [ 0 ]
			ifFalse: [ self builds first number ].
	queuedRuns := (items
			collect: [ :each | 
				number := number + 1.
				JcCoreRun
					queuedClient: client
					jobNames: names
					rawData: (Dictionary new
							at: 'number' put: number;
							at: 'queued' put: true;
							at: 'building' put: false;
							at: 'timestamp' put: (each at: 'inQueueSince' ifAbsent: [ nil ]);
							at: 'why' put: (each at: 'why' ifAbsent: [ nil ]);
							yourself) ]) reversed asArray.
	^ queuedRuns
]

{ #category : #builds }
JcCoreJob >> runAt: aNumberOrAlias [
	| path |
	path := (client jobPathSegmentsForNames: names) asOrderedCollection.
	path add: aNumberOrAlias asString.
	^ JcCoreRun
		client: client
		jobNames: names
		rawData: (client
				getJsonAtPathSegments: path
				tree: 'number,result,building,duration,timestamp,url')
]

{ #category : #accessing }
JcCoreJob >> url [
	^ rawData at: 'url' ifAbsent: [ nil ]
]

{ #category : #urls }
JcCoreJob >> webUrl [
	^ (rawData at: 'url' ifAbsent: [ nil ])
		ifNil: [ client webUrlForPathSegments: (client jobPathSegmentsForNames: names) ]
]
