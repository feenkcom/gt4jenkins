"
Offline examples for {{gtClass:JcCoreJob}} and {{gtClass:JcCoreRun}}, including nested folders and incomplete builds.
"
Class {
	#name : #JcCoreModelExamples,
	#superclass : #Object,
	#category : #'GToolkit-Jenkins-CoreAPI-Examples'
}

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
