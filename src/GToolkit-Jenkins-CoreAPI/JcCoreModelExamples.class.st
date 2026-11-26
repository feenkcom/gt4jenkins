"
Offline examples for {{gtClass:JcCoreJob}} and {{gtClass:JcCoreRun}}, including nested folders and incomplete builds.
"
Class {
	#name : #JcCoreModelExamples,
	#superclass : #Object,
	#category : #'GToolkit-Jenkins-CoreAPI-Examples'
}

{ #category : #examples }
JcCoreModelExamples >> buildsCachedUntilRefresh [
	<gtExample>
	| client job requests initial refreshed |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example'.
	client
		responseProvider: [ :url | 
			self assert: (url queryAt: 'tree') equals: 'builds[number,url]'.
			requests := requests + 1.
			requests = 1
				ifTrue: [ '{"builds":[{"number":7,"url":"https://jenkins.example/job/demo/7/"}]}' ]
				ifFalse: [ '{"builds":[{"number":8,"url":"https://jenkins.example/job/demo/8/"}]}' ] ].
	job := JcCoreJob
			client: client
			names: #('demo')
			rawData: (Dictionary new
					at: 'name' put: 'demo';
					yourself).
	initial := job builds.
	self assert: initial first number equals: 7.
	self assert: job builds == initial.
	self assert: requests equals: 1.
	refreshed := job refreshBuilds.
	self assert: refreshed first number equals: 8.
	self assert: refreshed ~~ initial.
	self assert: job builds == refreshed.
	self assert: requests equals: 2.
	^ job
]

{ #category : #examples }
JcCoreModelExamples >> emptyBuildsSurviveFailedRefresh [
	<gtExample>
	| client job requests cached |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example'.
	client
		responseProvider: [ :url | 
			requests := requests + 1.
			requests = 1 ifFalse: [ self error: 'Fixture request failed' ].
			'{"builds":[]}' ].
	job := JcCoreJob
			client: client
			names: #('empty')
			rawData: (Dictionary new
					at: 'name' put: 'empty';
					yourself).
	cached := job builds.
	self assert: cached isEmpty.
	self assert: job builds == cached.
	[ job refreshBuilds ]
		on: Error
		do: [ :exception | self assert: exception messageText equals: 'Fixture request failed' ].
	self assert: job builds == cached.
	self assert: requests equals: 2.
	^ job
]

{ #category : #examples }
JcCoreModelExamples >> emptyFolderJobsStayCached [
	<gtExample>
	| client folder requests |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example'.
	client
		responseProvider: [ :url | 
			requests := requests + 1.
			'{"jobs":[]}' ].
	folder := JcCoreJob
			client: client
			names: #('empty')
			rawData: (Dictionary new
					at: 'name' put: 'empty';
					yourself).
	self assert: folder jobs isEmpty.
	self assert: folder jobs isEmpty.
	self assert: requests equals: 1.
	self assert: folder refreshJobs isEmpty.
	self assert: requests equals: 2.
	^ folder
]

{ #category : #examples }
JcCoreModelExamples >> folderCachesAreIndependent [
	<gtExample>
	| client firstFolder secondFolder requests |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example'.
	client
		responseProvider: [ :url | 
			requests := requests + 1.
			'{"jobs":[]}' ].
	firstFolder := JcCoreJob
			client: client
			names: #('first')
			rawData: (Dictionary new
					at: 'name' put: 'first';
					yourself).
	secondFolder := JcCoreJob
			client: client
			names: #('second')
			rawData: (Dictionary new
					at: 'name' put: 'second';
					yourself).
	firstFolder jobs.
	secondFolder jobs.
	firstFolder jobs.
	self assert: requests equals: 2.
	firstFolder refreshJobs.
	self assert: requests equals: 3.
	self assert: secondFolder jobs isEmpty.
	self assert: requests equals: 3.
	^ firstFolder
]

{ #category : #examples }
JcCoreModelExamples >> folderJobsCachedUntilRefresh [
	<gtExample>
	| client folder requests initial refreshed |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example'.
	client
		responseProvider: [ :url | 
			self
				assert: url asString
				equals: 'https://jenkins.example/job/folder/api/json?tree=jobs%5Bname,fullName,url%5D'.
			requests := requests + 1.
			requests = 1
				ifTrue: [ '{"jobs":[{"name":"before"}]}' ]
				ifFalse: [ '{"jobs":[{"name":"after"}]}' ] ].
	folder := JcCoreJob
			client: client
			names: #('folder')
			rawData: (Dictionary new
					at: 'name' put: 'folder';
					yourself).
	initial := folder jobs.
	self assert: folder jobs == initial.
	self assert: requests equals: 1.
	refreshed := folder refreshJobs.
	self assert: refreshed first name equals: 'after'.
	self assert: refreshed ~~ initial.
	self assert: folder jobs == refreshed.
	self assert: requests equals: 2.
	^ folder
]

{ #category : #examples }
JcCoreModelExamples >> folderWithJobsView [
	<gtExample>
	| client folder |
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/ci'.
	client
		responseProvider: [ :url | 
			self
				assert: url asString
				equals: 'https://jenkins.example/ci/job/folder/api/json?tree=jobs%5Bname,fullName,url%5D'.
			'{"jobs":[{"name":"demo","fullName":"folder/demo","url":"https://jenkins.example/ci/job/folder/job/demo/"}]}' ].
	folder := JcCoreJob
			client: client
			names: #('folder')
			rawData: (Dictionary new
					at: 'name' put: 'folder';
					yourself).
	self assert: folder jobs first fullName equals: 'folder/demo'.
	^ folder
]

{ #category : #examples }
JcCoreModelExamples >> jobWithBuildsView [
	<gtExample>
	| client job |
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/ci'.
	client
		responseProvider: [ :url | 
			self
				assert: url asString
				equals: 'https://jenkins.example/ci/job/demo/api/json?tree=builds%5Bnumber,url%5D'.
			'{"builds":[{"number":7,"url":"https://jenkins.example/ci/job/demo/7/"}]}' ].
	job := JcCoreJob
			client: client
			names: #('demo')
			rawData: (Dictionary new
					at: 'name' put: 'demo';
					yourself).
	self assert: job builds first number equals: 7.
	^ job
]

{ #category : #examples }
JcCoreModelExamples >> nestedFolderJobs [
	<gtExample>
	| client folder branch |
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/ci'.
	client
		responseProvider: [ :url | 
			url asString
				= 'https://jenkins.example/ci/api/json?tree=jobs%5Bname,fullName,url%5D'
				ifTrue: [ '{"jobs":[{"name":"folder","fullName":"folder","url":"https://jenkins.example/ci/job/folder/"}]}' ]
				ifFalse: [ self
						assert: url asString
						equals: 'https://jenkins.example/ci/job/folder/api/json?tree=jobs%5Bname,fullName,url%5D'.
					'{"jobs":[{"name":"feature/x","fullName":"folder/feature/x","url":"https://jenkins.example/ci/job/folder/job/feature%2Fx/"}]}' ] ].
	folder := client jobs first.
	branch := folder jobs first.
	self assert: folder name equals: 'folder'.
	self assert: branch names equals: #('folder' 'feature/x').
	self assert: branch fullName equals: 'folder/feature/x'.
	^ branch
]

{ #category : #examples }
JcCoreModelExamples >> reinitializeJobClearsBuilds [
	<gtExample>
	| client job requests |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example'.
	client
		responseProvider: [ :url | 
			requests := requests + 1.
			requests = 1
				ifTrue: [ self assert: (url pathSegments includes: 'first') ]
				ifFalse: [ self assert: (url pathSegments includes: 'second') ].
			'{"builds":[]}' ].
	job := JcCoreJob
			client: client
			names: #('first')
			rawData: (Dictionary new
					at: 'name' put: 'first';
					yourself).
	self assert: job builds isEmpty.
	job
		client: client
		names: #('second')
		rawData: (Dictionary new
				at: 'name' put: 'second';
				yourself).
	self assert: job builds isEmpty.
	self assert: requests equals: 2.
	^ job
]

{ #category : #examples }
JcCoreModelExamples >> runningBuildForViews [
	<gtExample>
	| client run |
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/ci'.
	client
		responseProvider: [ :url | 
			self
				assert: url asString
				equals: 'https://jenkins.example/ci/job/demo/8/api/json?tree=number,result,timestamp,duration,url,building'.
			'{"number":8,"building":true,"result":null,"timestamp":1730000001000,"duration":0}' ].
	run := JcCoreRun
			client: client
			jobNames: #('demo')
			rawData: (Dictionary new
					at: 'number' put: 8;
					at: 'url' put: 'https://jenkins.example/ci/job/demo/8/';
					yourself).
	self assert: run rawData size equals: 2.
	^ run
]

{ #category : #examples }
JcCoreModelExamples >> runningBuildLoadsDetailsOnce [
	<gtExample>
	| client job run requestCount |
	requestCount := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/ci/'.
	client
		responseProvider: [ :url | 
			requestCount := requestCount + 1.
			requestCount = 1
				ifTrue: [ self
						assert: url asString
						equals: 'https://jenkins.example/ci/job/folder/job/feature%2Fx/api/json?tree=builds%5Bnumber,url%5D'.
					'{"builds":[{"number":42,"url":"https://jenkins.example/ci/job/folder/job/feature%2Fx/42/"}]}' ]
				ifFalse: [ self
						assert: url asString
						equals: 'https://jenkins.example/ci/job/folder/job/feature%2Fx/42/api/json?tree=number,result,timestamp,duration,url,building'.
					'{"number":42,"building":true,"result":null,"timestamp":1730000000000}' ] ].
	job := JcCoreJob
			client: client
			names: #('folder' 'feature/x')
			rawData: (Dictionary new
					at: 'name' put: 'feature/x';
					yourself).
	run := job builds first.
	self assert: run number equals: 42.
	self assert: run building.
	self assert: run result equals: nil.
	self assert: run duration equals: nil.
	self assert: run timestamp equals: 1730000000000.
	self assert: requestCount equals: 2.
	^ run
]
