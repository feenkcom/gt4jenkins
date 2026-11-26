"
Offline examples for {{gtClass:JcCoreClient}}. They inspect generated URLs and parse fixture JSON without contacting Jenkins.
"
Class {
	#name : #JcCoreClientExamples,
	#superclass : #Object,
	#category : #'GToolkit-Jenkins-CoreAPI-Examples'
}

{ #category : #examples }
JcCoreClientExamples >> changingClientSettingsInvalidatesJobs [
	<gtExample>
	| client requests |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example'.
	client
		responseProvider: [ :url | 
			requests := requests + 1.
			'{"jobs":[]}' ].
	self assert: client jobs isEmpty.
	self assert: client jobs isEmpty.
	self assert: requests equals: 1.
	client baseUrl: 'https://jenkins.example/ci'.
	self assert: client jobs isEmpty.
	self assert: requests equals: 2.
	client username: 'user' token: 'fixture-token'.
	self assert: client jobs isEmpty.
	self assert: requests equals: 3.
	client
		responseProvider: [ :url | 
			requests := requests + 1.
			'{"jobs":[]}' ].
	self assert: client jobs isEmpty.
	self assert: requests equals: 4.
	^ client
]

{ #category : #examples }
JcCoreClientExamples >> clientWithJobs [
	<gtExample>
	| client |
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/ci'.
	client
		responseProvider: [ :url | 
			self
				assert: url asString
				equals: 'https://jenkins.example/ci/api/json?tree=jobs%5Bname,fullName,url%5D'.
			'{"jobs":[{"name":"demo","fullName":"demo","url":"https://jenkins.example/ci/job/demo/"}]}' ].
	self assert: client jobs first name equals: 'demo'.
	^ client
]

{ #category : #examples }
JcCoreClientExamples >> completedBuild [
	<gtExample>
	| client run |
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/ci'.
	client
		responseProvider: [ :url | 
			(url queryAt: 'tree') = 'name,fullName,url'
				ifTrue: [ '{"name":"demo","fullName":"demo","url":"https://jenkins.example/ci/job/demo/"}' ]
				ifFalse: [ (url queryAt: 'tree') = 'builds[number,url]'
						ifTrue: [ '{"builds":[{"number":7,"url":"https://jenkins.example/ci/job/demo/7/"}]}' ]
						ifFalse: [ '{"number":7,"building":false,"result":"SUCCESS","timestamp":1730000000000,"duration":1200,"url":"https://jenkins.example/ci/job/demo/7/"}' ] ] ].
	run := (client jobAtNames: #('demo')) builds first.
	self assert: run result equals: 'SUCCESS'.
	self assert: run building equals: false.
	self assert: run duration equals: 1200.
	^ run
]

{ #category : #examples }
JcCoreClientExamples >> controllerContextAndEncodedJobPath [
	<gtExample>
	| client url |
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/ci/'.
	url := client
			urlForPathSegments: #('job' 'a b' 'job' 'feature/x')
			tree: 'number,result'.
	self
		assert: url asString
		equals: 'https://jenkins.example/ci/job/a%20b/job/feature%2Fx/api/json?tree=number,result'.
	^ url
]

{ #category : #examples }
JcCoreClientExamples >> failedRefreshKeepsClientJobs [
	<gtExample>
	| client requests cached |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example'.
	client
		responseProvider: [ :url | 
			requests := requests + 1.
			requests = 1 ifFalse: [ self error: 'Fixture request failed' ].
			'{"jobs":[{"name":"kept"}]}' ].
	cached := client jobs.
	[ client refreshJobs ]
		on: Error
		do: [ :exception | self assert: exception messageText equals: 'Fixture request failed' ].
	self assert: client jobs == cached.
	self assert: requests equals: 2.
	^ client
]

{ #category : #examples }
JcCoreClientExamples >> jenkinsJobUrl [
	<gtExample>
	| client job |
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.feenk.com'.
	client
		responseProvider: [ :url | 
			self
				assert: url pathSegments asArray
				equals: #('job' 'feenkcom' 'job' 'gtoolkit' 'job' 'main' 'api' 'json').
			(url queryAt: 'tree') = 'name,fullName,url'
				ifTrue: [ '{"name":"main","fullName":"feenkcom/gtoolkit/main","url":"https://jenkins.feenk.com/job/feenkcom/job/gtoolkit/job/main/"}' ]
				ifFalse: [ self assert: (url queryAt: 'tree') equals: 'builds[number,url]'.
					'{"builds":[{"number":7,"url":"https://jenkins.feenk.com/job/feenkcom/job/gtoolkit/job/main/7/"}]}' ] ].
	job := client
			jobAtUrl: 'https://jenkins.feenk.com/job/feenkcom/job/gtoolkit/job/main/'.
	self assert: job names equals: #('feenkcom' 'gtoolkit' 'main').
	self assert: job fullName equals: 'feenkcom/gtoolkit/main'.
	self assert: job builds first number equals: 7.
	^ job
]

{ #category : #examples }
JcCoreClientExamples >> jobUrlWithContextAndEncodedBranch [
	<gtExample>
	| client job |
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/ci/'.
	client
		responseProvider: [ :url | 
			self
				assert: url asString
				equals: 'https://jenkins.example/ci/job/team/job/feature%2Ftest/api/json?tree=name,fullName,url'.
			'{"name":"feature/test","fullName":"team/feature/test","url":"https://jenkins.example/ci/job/team/job/feature%2Ftest/"}' ].
	job := client
			jobAtUrl: 'https://jenkins.example/ci/job/team/job/feature%2Ftest/'.
	self assert: job names equals: #('team' 'feature/test').
	^ job
]

{ #category : #examples }
JcCoreClientExamples >> jobsCachedUntilRefresh [
	<gtExample>
	| client requests initial refreshed |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example'.
	client
		responseProvider: [ :url | 
			self assert: (url queryAt: 'tree') equals: 'jobs[name,fullName,url]'.
			requests := requests + 1.
			requests = 1
				ifTrue: [ '{"jobs":[{"name":"before"}]}' ]
				ifFalse: [ '{"jobs":[{"name":"after"}]}' ] ].
	initial := client jobs.
	self assert: client jobs == initial.
	self assert: requests equals: 1.
	refreshed := client refreshJobs.
	self assert: refreshed first name equals: 'after'.
	self assert: refreshed ~~ initial.
	self assert: client jobs == refreshed.
	self assert: requests equals: 2.
	^ client
]

{ #category : #examples }
JcCoreClientExamples >> parseFixtureResponse [
	<gtExample>
	| client response |
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/ci'.
	client
		responseProvider: [ :url | 
			self
				assert: url asString
				equals: 'https://jenkins.example/ci/api/json?tree=jobs%5Bname,url%5D'.
			'{"jobs":[{"name":"example","url":"https://jenkins.example/ci/job/example/"}]}' ].
	response := client getJsonAtPathSegments: #() tree: 'jobs[name,url]'.
	self assert: ((response at: 'jobs') first at: 'name') equals: 'example'.
	^ response
]

{ #category : #examples }
JcCoreClientExamples >> rejectBlueOceanUrl [
	<gtExample>
	| client rejected |
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.feenk.com'.
	rejected := false.
	[ client
		jobAtUrl: 'https://jenkins.feenk.com/blue/rest/organizations/jenkins/pipelines/feenkcom/pipelines/gtoolkit/branches/main/' ]
		on: Error
		do: [ :exception | 
			self
				assert: exception messageText
				equals: 'Expected a Jenkins job URL with job/name segments'.
			rejected := true ].
	self assert: rejected.
	^ client
]

{ #category : #examples }
JcCoreClientExamples >> rejectUnrelatedJobUrl [
	<gtExample>
	| client rejected |
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/ci'.
	rejected := false.
	[ client jobAtUrl: 'https://other.example/ci/job/demo/' ]
		on: Error
		do: [ :exception | 
			self
				assert: exception messageText
				equals: 'Job URL must belong to the configured Jenkins controller'.
			rejected := true ].
	self assert: rejected.
	^ client
]
