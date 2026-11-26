"
Offline examples for {{gtClass:JcCoreJob}} and {{gtClass:JcCoreRun}}, including nested folders and incomplete builds.
"
Class {
	#name : #JcCoreModelExamples,
	#superclass : #Object,
	#category : #'GToolkit-Jenkins-CoreAPI-Examples'
}

{ #category : #examples }
JcCoreModelExamples >> artifactContentsCached [
	<gtExample>
	| client run artifact requests |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/ci/'.
	client
		responseProvider: [ :url | 
			requests := requests + 1.
			self
				assert: url asString
				equals: 'https://jenkins.example/ci/job/folder/job/feature%2Fx/7/artifact/logs/build%20output.txt'.
			'Build output' ].
	run := JcCoreRun
			client: client
			jobNames: #('folder' 'feature/x')
			rawData: (Dictionary new
					at: 'number' put: 7;
					yourself).
	artifact := JcCoreArtifact
			run: run
			rawData: (Dictionary new
					at: 'fileName' put: 'build output.txt';
					at: 'relativePath' put: 'logs/build output.txt';
					yourself).
	self assert: artifact data equals: 'Build output'.
	self assert: artifact data equals: 'Build output'.
	self assert: requests equals: 1.
	^ artifact
]

{ #category : #examples }
JcCoreModelExamples >> buildHistoryWithStatuses [
	<gtExample>
	| client job runs requests |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example'.
	client
		responseProvider: [ :url | 
			requests := requests + 1.
			self
				assert: (url queryAt: 'tree')
				equals: 'builds[number,url,result,building,duration,timestamp]'.
			'{"builds":[{"number":7,"url":"https://jenkins.example/job/demo/7/","result":"SUCCESS","building":false,"duration":1200,"timestamp":1730000000000},{"number":8,"url":"https://jenkins.example/job/demo/8/","result":null,"building":true,"duration":0,"timestamp":1730000001000},{"number":9,"url":"https://jenkins.example/job/demo/9/","result":null,"building":false,"duration":null,"timestamp":null}]}' ].
	job := JcCoreJob
			client: client
			names: #('demo')
			rawData: (Dictionary new
					at: 'name' put: 'demo';
					yourself).
	runs := job builds.
	self assert: runs size equals: 3.
	self assert: runs first resultText equals: 'SUCCESS'.
	self assert: runs first durationText isEmpty not.
	self assert: runs first startTimeText isEmpty not.
	self assert: runs second resultText equals: 'RUNNING'.
	self assert: runs second resultBackgroundColor notNil.
	self assert: runs third resultText equals: 'UNKNOWN'.
	self assert: runs third durationText equals: ''.
	self assert: runs third startTimeText equals: ''.
	self assert: requests equals: 1.
	^ job
]

{ #category : #examples }
JcCoreModelExamples >> buildStatusIconScripter [
	<gtExample>
	<return: #BlScripter>
	| scripter run |
	run := self buildHistoryWithStatuses builds first.
	scripter := BlScripter new.
	scripter element: run statusIcon.
	self assert: (scripter element isKindOf: BlElement).
	^ scripter
]

{ #category : #examples }
JcCoreModelExamples >> buildWithArtifacts [
	<gtExample>
	| client run requests artifact |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/ci/'.
	client
		responseProvider: [ :url | 
			requests := requests + 1.
			self
				assert: url asString
				equals: 'https://jenkins.example/ci/job/folder/job/feature%2Fx/7/api/json?tree=artifacts%5BfileName,relativePath%5D'.
			'{"artifacts":[{"fileName":"build output.txt","relativePath":"logs/build output.txt"}]}' ].
	run := JcCoreRun
			client: client
			jobNames: #('folder' 'feature/x')
			rawData: (Dictionary new
					at: 'number' put: 7;
					yourself).
	artifact := run artifacts first.
	self assert: artifact class equals: JcCoreArtifact.
	self assert: artifact name equals: 'build output.txt'.
	self assert: artifact path equals: 'logs/build output.txt'.
	self
		assert: artifact url
		equals: 'https://jenkins.example/ci/job/folder/job/feature%2Fx/7/artifact/logs/build%20output.txt'.
	self assert: run artifacts first == artifact.
	self assert: requests equals: 1.
	^ run
]

{ #category : #examples }
JcCoreModelExamples >> buildWithLegacyStages [
	<gtExample>
	| client run requests |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/'.
	client
		responseProvider: [ :url | 
			requests := requests + 1.
			url pathSegments last = 'tree'
				ifTrue: [ (ZnHttpUnsuccessful response: (ZnResponse notFound: url)) signal ]
				ifFalse: [ '{"stages":[{"id":"1","name":"Build","status":"SUCCESS","durationMillis":1000}]}' ] ].
	run := JcCoreRun
			client: client
			jobNames: #('main')
			rawData: (Dictionary new
					at: 'number' put: 7;
					yourself).
	self assert: run stages first name equals: 'Build'.
	self assert: run stages first durationMillis equals: 1000.
	self assert: run rootStages size equals: 1.
	self assert: requests equals: 2.
	^ run
]

{ #category : #examples }
JcCoreModelExamples >> buildWithParallelStages [
	<gtExample>
	| client run roots parallel branch |
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/'.
	client
		responseProvider: [ :url | '{"status":"ok","data":{"complete":true,"stages":[{"id":"1","name":"Build","state":"success","children":[]},{"id":"2","name":"Parallel","type":"PARALLEL_BLOCK","state":"success","children":[{"id":"3","name":"Linux","type":"PARALLEL","isSequential":false,"children":[{"id":"4","name":"Test Linux","state":"success","children":[]}]},{"id":"5","name":"Mac","type":"PARALLEL","isSequential":false,"children":[]}]},{"id":"6","name":"Deploy","state":"success","children":[]}]}}' ].
	run := JcCoreRun
			client: client
			jobNames: #('main')
			rawData: (Dictionary new
					at: 'number' put: 7;
					yourself).
	roots := run rootStages.
	self assert: roots size equals: 3.
	parallel := roots second.
	self assert: parallel isParallel.
	self assert: parallel children size equals: 2.
	branch := parallel children first.
	self assert: branch parent == parallel.
	self assert: branch children first parent == branch.
	self assert: run stages size equals: 6.
	^ run
]

{ #category : #examples }
JcCoreModelExamples >> buildWithProblematicTests [
	<gtExample>
	| client run requests |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/'.
	client
		responseProvider: [ :url | 
			requests := requests + 1.
			self
				assert: (url asString includesSubstring: '/job/main/7/testReport/api/json?tree=').
			'{"suites":[{"cases":[{"className":"Demo","name":"passes","status":"PASSED"},{"className":"Demo","name":"fails","status":"FAILED"},{"className":"Demo","name":"skips","status":"SKIPPED"}]}]}' ].
	run := JcCoreRun
			client: client
			jobNames: #('main')
			rawData: (Dictionary new
					at: 'number' put: 7;
					at: 'building' put: false;
					yourself).
	self assert: run problematicTests size equals: 2.
	self assert: (run problematicTests first at: 'name') equals: 'fails'.
	self assert: requests equals: 1.
	^ run
]

{ #category : #examples }
JcCoreModelExamples >> buildWithStages [
	<gtExample>
	| client run requests |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/ci/'.
	client
		responseProvider: [ :url | 
			requests := requests + 1.
			self
				assert: url asString
				equals: 'https://jenkins.example/ci/job/folder/job/main/7/stages/tree'.
			'{"status":"ok","data":{"complete":true,"stages":[{"id":"1","name":"Build","state":"success","totalDurationMillis":1200,"children":[]},{"id":"2","name":"Test","state":"failed","totalDurationMillis":3000,"children":[]}]}}' ].
	run := JcCoreRun
			client: client
			jobNames: #('folder' 'main')
			rawData: (Dictionary new
					at: 'number' put: 7;
					yourself).
	self assert: run stages size equals: 2.
	self assert: run stages first class equals: JcCoreStage.
	self assert: run stages last status equals: 'FAILED'.
	self assert: run rootStages size equals: 2.
	self assert: requests equals: 1.
	self assert: run refreshStages size equals: 2.
	self assert: requests equals: 2.
	^ run
]

{ #category : #examples }
JcCoreModelExamples >> buildWithoutArtifacts [
	<gtExample>
	| client run requests |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example'.
	client
		responseProvider: [ :url | 
			requests := requests + 1.
			'{}' ].
	run := JcCoreRun
			client: client
			jobNames: #('demo')
			rawData: (Dictionary new
					at: 'number' put: 8;
					yourself).
	self assert: run artifacts isEmpty.
	self assert: run artifacts isEmpty.
	self assert: requests equals: 1.
	^ run
]

{ #category : #examples }
JcCoreModelExamples >> buildWithoutStages [
	<gtExample>
	| client run requests |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/'.
	client
		responseProvider: [ :url | 
			requests := requests + 1.
			(ZnHttpUnsuccessful response: (ZnResponse notFound: url)) signal ].
	run := JcCoreRun
			client: client
			jobNames: #('freestyle')
			rawData: (Dictionary new
					at: 'number' put: 1;
					yourself).
	self assert: run stages isEmpty.
	self assert: run rootStages isEmpty.
	self assert: run stages isEmpty.
	self assert: requests equals: 2.
	^ run
]

{ #category : #examples }
JcCoreModelExamples >> buildWithoutTestReport [
	<gtExample>
	| client run requests |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/'.
	client
		responseProvider: [ :url | 
			requests := requests + 1.
			(ZnHttpUnsuccessful response: (ZnResponse notFound: url)) signal ].
	run := JcCoreRun
			client: client
			jobNames: #('main')
			rawData: (Dictionary new
					at: 'number' put: 7;
					at: 'building' put: false;
					yourself).
	self assert: run problematicTests isEmpty.
	self assert: run problematicTests isEmpty.
	self assert: requests equals: 1.
	^ run
]

{ #category : #examples }
JcCoreModelExamples >> buildsCachedUntilRefresh [
	<gtExample>
	| client job requests initial refreshed |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example'.
	client
		responseProvider: [ :url | 
			self
				assert: (url queryAt: 'tree')
				equals: 'builds[number,url,result,building,duration,timestamp]'.
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
JcCoreModelExamples >> imageArtifact [
	<gtExample>
	| client run artifact bytes |
	bytes := ZnBase64Encoder new
			decode: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII='.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/'.
	client responseProvider: [ :url | bytes ].
	run := JcCoreRun
			client: client
			jobNames: #('demo')
			rawData: (Dictionary new
					at: 'number' put: 8;
					yourself).
	artifact := JcCoreArtifact
			run: run
			rawData: (Dictionary new
					at: 'fileName' put: 'figure.png';
					at: 'relativePath' put: 'figure.png';
					yourself).
	self assert: artifact isImage.
	self assert: artifact data equals: bytes.
	^ artifact
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
				equals: 'https://jenkins.example/ci/job/demo/api/json?tree=builds%5Bnumber,url,result,building,duration,timestamp%5D'.
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
JcCoreModelExamples >> legacyStagesHaveNoEdges [
	<gtExample>
	<return: #JcCoreRun>
	| run |
	run := self buildWithLegacyStages.
	self assert: run hasStageTree not.
	self assert: run stageEdges isEmpty.
	^ run
]

{ #category : #examples }
JcCoreModelExamples >> missingArtifactContents [
	<gtExample>
	| client run artifact requests |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/'.
	client
		responseProvider: [ :url | 
			requests := requests + 1.
			(ZnHttpUnsuccessful response: (ZnResponse notFound: url)) signal ].
	run := JcCoreRun
			client: client
			jobNames: #('demo')
			rawData: (Dictionary new
					at: 'number' put: 8;
					yourself).
	artifact := JcCoreArtifact
			run: run
			rawData: (Dictionary new
					at: 'fileName' put: 'missing.txt';
					at: 'relativePath' put: 'missing.txt';
					yourself).
	self assert: artifact data isNil.
	self assert: artifact data isNil.
	self assert: requests equals: 1.
	^ artifact
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
JcCoreModelExamples >> parallelStageEdges [
	<gtExample>
	<return: #JcCoreRun>
	| run names |
	run := self buildWithParallelStages.
	names := run stageEdges
			collect: [ :edge | edge key name , '->' , edge value name ].
	self
		assert: names asSet
		equals: #('Build->Parallel' 'Parallel->Linux' 'Parallel->Mac' 'Linux->Test Linux' 'Test Linux->Deploy' 'Mac->Deploy')
				asSet.
	self assert: names size equals: 6.
	^ run
]

{ #category : #examples }
JcCoreModelExamples >> pharoDebugLogArtifact [
	<gtExample>
	| client run artifact |
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/'.
	client responseProvider: [ :url | '' ].
	run := JcCoreRun
			client: client
			jobNames: #('demo')
			rawData: (Dictionary new
					at: 'number' put: 8;
					yourself).
	artifact := JcCoreArtifact
			run: run
			rawData: (Dictionary new
					at: 'fileName' put: 'PharoDebug.log';
					at: 'relativePath' put: 'PharoDebug.log';
					yourself).
	self assert: artifact isPharoDebugLog.
	^ artifact
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
						equals: 'https://jenkins.example/ci/job/folder/job/feature%2Fx/api/json?tree=builds%5Bnumber,url,result,building,duration,timestamp%5D'.
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

{ #category : #examples }
JcCoreModelExamples >> runningBuildWithoutTestReport [
	<gtExample>
	| client run requests |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/'.
	client
		responseProvider: [ :url | 
			requests := requests + 1.
			self error: 'Unexpected request' ].
	run := JcCoreRun
			client: client
			jobNames: #('main')
			rawData: (Dictionary new
					at: 'number' put: 7;
					at: 'building' put: true;
					yourself).
	self assert: run problematicTests isEmpty.
	self assert: requests equals: 0.
	^ run
]

{ #category : #examples }
JcCoreModelExamples >> runningStageTree [
	<gtExample>
	| client run |
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/'.
	client
		responseProvider: [ :url | '{"status":"ok","data":{"complete":false,"stages":[{"id":"1","name":"Build","state":"running","totalDurationMillis":-1,"children":[]}]}}' ].
	run := JcCoreRun
			client: client
			jobNames: #('main')
			rawData: (Dictionary new
					at: 'number' put: 7;
					at: 'building' put: true;
					yourself).
	self assert: run stages first status equals: 'RUNNING'.
	self assert: run stages first durationText isString.
	^ run
]

{ #category : #examples }
JcCoreModelExamples >> sequentialStageEdges [
	<gtExample>
	<return: #JcCoreRun>
	| run |
	run := self buildWithStages.
	self assert: run hasStageTree.
	self assert: run stageEdges size equals: 1.
	self assert: run stageEdges first key name equals: 'Build'.
	self assert: run stageEdges first value name equals: 'Test'.
	^ run
]

{ #category : #examples }
JcCoreModelExamples >> stageCardScripter [
	<gtExample>
	<return: #BlScripter>
	| scripter stage elements labels |
	stage := self buildWithStages stages last.
	scripter := BlScripter new.
	scripter element: stage cardElement.
	elements := scripter element withAllChildrenBreadthFirst.
	labels := elements select: [ :each | each isKindOf: BrLabel ].
	self assert: (labels anySatisfy: [ :each | each text asString = 'Test' ]).
	self
		assert: (labels anySatisfy: [ :each | each text asString = stage durationText ]).
	self
		assert: (elements
				anySatisfy: [ :each | each background paint color = stage resultBackgroundColor ]).
	^ scripter
]

{ #category : #examples }
JcCoreModelExamples >> stagesMapView [
	<gtExample>
	<return: #JcCoreRun>
	| run view element cards |
	run := self buildWithParallelStages.
	view := run gtStagesMapFor: GtPhlowView empty.
	self assert: view title equals: 'Stages map'.
	element := view asElementDo: [ :each | each ].
	cards := element withAllChildrenBreadthFirst
			select: [ :each | each isKindOf: BrHorizontalPane ].
	self assert: cards size equals: run stages size.
	^ run
]
