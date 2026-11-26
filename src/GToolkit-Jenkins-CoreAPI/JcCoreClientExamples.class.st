"
Offline examples for {{gtClass:JcCoreClient}}. They inspect generated URLs and parse fixture JSON without contacting Jenkins.
"
Class {
	#name : #JcCoreClientExamples,
	#superclass : #Object,
	#category : #'GToolkit-Jenkins-CoreAPI-Examples'
}

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
