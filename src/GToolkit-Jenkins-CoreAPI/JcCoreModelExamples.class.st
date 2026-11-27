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
	self assert: run problematicTests first name equals: 'fails'.
	self assert: run problematicTests first stageNames isEmpty.
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
JcCoreModelExamples >> buildWithTestCases [
	<gtExample>
	<return: #JcCoreRun>
	| log run cases failed |
	log := OrderedCollection new.
	run := self reportRunLoggingTo: log.
	cases := run problematicTests.
	self assert: cases size equals: 3.
	self assert: (cases collect: #class) asSet asArray equals: {JcCoreTestCase}.
	self
		assert: (cases collect: #status) asArray
		equals: #('FAILED' 'SKIPPED' 'FAILED').
	failed := cases first.
	self assert: failed gtDisplayString equals: 'DemoExamples>>#fails'.
	self assert: failed isFailed.
	self assert: cases second isSkipped.
	self assert: failed stageNames asArray equals: #('Test Mac' 'Agent (arm-x)').
	self assert: log size equals: 1.
	self assert: run problematicTests == cases.
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

{ #category : #fixtures }
JcCoreModelExamples >> reportRunLoggingTo: aLog [
	| client |
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/'.
	client
		responseProvider: [ :url | 
			| text tree |
			text := url asString.
			aLog add: text.
			tree := url queryAt: 'tree' ifAbsent: [ '' ].
			(text includesSubstring: '/stages/tree')
				ifTrue: [ '{"status":"ok","data":{"complete":true,"stages":[{"id":"2","name":"Parallel","type":"PARALLEL_BLOCK","state":"success","children":[{"id":"3","name":"Agent (arm-x)","type":"PARALLEL","state":"failed","children":[{"id":"4","name":"Test Mac","state":"failed","children":[]}]},{"id":"5","name":"Agent (lin-x)","type":"PARALLEL","state":"success","children":[{"id":"6","name":"Test Linux","state":"success","children":[]}]}]}]}}' ]
				ifFalse: [ (text includesSubstring: '/testReport/')
						ifTrue: [ (tree includesSubstring: 'errorDetails')
								ifTrue: [ (tree endsWith: '{0,1}')
										ifTrue: [ '{"suites":[{"cases":[{"className":"Pkg.Examples.DemoExamples","name":"passes","status":"PASSED","errorDetails":null,"errorStackTrace":null,"skippedMessage":null},{"className":"Pkg.Examples.DemoExamples","name":"fails","status":"FAILED","errorDetails":"boom","errorStackTrace":"DemoExamples>>fails","skippedMessage":null},{"className":"Pkg.Examples.DemoExamples","name":"skips","status":"SKIPPED","errorDetails":null,"errorStackTrace":null,"skippedMessage":"not now"}]}]}' ]
										ifFalse: [ '{"suites":[{"cases":[{"className":"Pkg.Examples.DemoExamples","name":"fails","status":"FAILED","errorDetails":"boom on linux","errorStackTrace":"stack","skippedMessage":null}]}]}' ] ]
								ifFalse: [ '{"suites":[{"name":"Pkg-DemoExamples","nodeId":"9","enclosingBlockNames":["Test Mac","Agent (arm-x)"],"cases":[{"className":"Pkg.Examples.DemoExamples","name":"passes","status":"PASSED"},{"className":"Pkg.Examples.DemoExamples","name":"fails","status":"FAILED"},{"className":"Pkg.Examples.DemoExamples","name":"skips","status":"SKIPPED"}]},{"name":"Pkg-DemoExamples","nodeId":"10","enclosingBlockNames":["Test Linux","Agent (lin-x)"],"cases":[{"className":"Pkg.Examples.DemoExamples","name":"fails","status":"FAILED"}]}]}' ] ]
						ifFalse: [ '{"artifacts":[{"fileName":"step.png","relativePath":"artifacts/arm-x/gt-examples/pharo-local/scripter/DemoExamples/fails/step.png"},{"fileName":"step-events-all.txt","relativePath":"artifacts/arm-x/gt-examples/pharo-local/scripter/DemoExamples/fails/step-events-all.txt"},{"fileName":"step.png","relativePath":"artifacts/lin-x/gt-examples/pharo-local/scripter/DemoExamples/fails/step.png"},{"fileName":"step.png","relativePath":"artifacts/arm-x/gt-examples/pharo-local/scripter/OtherExamples/other/step.png"},{"fileName":"PharoDebug.log","relativePath":"artifacts/arm-x/gt-examples/PharoDebug.log"}]}' ] ] ].
	^ JcCoreRun
		client: client
		jobNames: #('main')
		rawData: (Dictionary new
				at: 'number' put: 7;
				at: 'building' put: false;
				yourself)
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
JcCoreModelExamples >> stageStatusIconScripter [
	<gtExample>
	<return: #BlScripter>
	| scripter stage |
	stage := self buildWithStages stages last.
	scripter := BlScripter new.
	scripter element: stage statusIcon.
	self
		assert: scripter element background paint color
		equals: stage resultBackgroundColor.
	self assert: scripter element geometry class equals: BlCircleGeometry.
	^ scripter
]

{ #category : #examples }
JcCoreModelExamples >> stageTestCasesAndArtifacts [
	<gtExample>
	<return: #JcCoreRun>
	| run mac linux agent |
	run := self reportRunLoggingTo: OrderedCollection new.
	mac := run stages detect: [ :each | each name = 'Test Mac' ].
	linux := run stages detect: [ :each | each name = 'Test Linux' ].
	agent := run stages detect: [ :each | each name = 'Agent (arm-x)' ].
	self assert: mac testCases size equals: 2.
	self assert: linux testCases size equals: 1.
	self assert: agent testCases size equals: 2.
	self
		assert: (run stages detect: [ :each | each name = 'Parallel' ]) testCases isEmpty.
	self assert: mac agentTarget equals: 'arm-x'.
	self
		assert: (mac artifacts collect: #name) asArray
		equals: #('step.png' 'step-events-all.txt' 'step.png' 'PharoDebug.log').
	self assert: (run stageForTestCase: run problematicTests third) == linux.
	self
		assert: (run stages detect: [ :each | each name = 'Parallel' ]) artifacts isEmpty.
	^ run
]

{ #category : #examples }
JcCoreModelExamples >> stageViews [
	<gtExample>
	<return: #JcCoreStage>
	| stage stepsView childrenView logView |
	stage := self stageWithSteps.
	stepsView := stage gtStepsFor: GtPhlowView empty.
	self assert: stepsView title equals: 'Steps'.
	self assert: (stepsView asElementDo: [ :each | each ]) notNil.
	childrenView := self buildWithParallelStages rootStages second
			gtChildrenFor: GtPhlowView empty.
	self assert: (childrenView asElementDo: [ :each | each ]) notNil.
	logView := self stepWithLog gtLogFor: GtPhlowView empty.
	self assert: (logView asElementDo: [ :each | each ]) notNil.
	self
		assert: (self stepWithoutLog gtLogFor: GtPhlowView empty) title
		equals: 'Log'.
	^ stage
]

{ #category : #examples }
JcCoreModelExamples >> stageWithSteps [
	<gtExample>
	<return: #JcCoreStage>
	| client run stage requests steps |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/ci/'.
	client
		responseProvider: [ :url | 
			requests := requests + 1.
			self
				assert: url asString
				equals: 'https://jenkins.example/ci/job/folder/job/main/7/execution/node/12/wfapi/describe'.
			'{"id":"12","name":"Test","stageFlowNodes":[{"id":"13","name":"Shell Script","status":"SUCCESS","parameterDescription":"echo ok","durationMillis":1500},{"id":"14","name":"Shell Script","status":"FAILED","parameterDescription":null,"durationMillis":-1}]}' ].
	run := JcCoreRun
			client: client
			jobNames: #('folder' 'main')
			rawData: (Dictionary new
					at: 'number' put: 7;
					yourself).
	stage := JcCoreStage
			run: run
			parent: nil
			rawData: (Dictionary new
					at: 'id' put: '12';
					at: 'name' put: 'Test';
					yourself).
	steps := stage steps.
	self assert: steps size equals: 2.
	self assert: steps first class equals: JcCoreStep.
	self assert: steps first gtDisplayString equals: 'Shell Script - echo ok'.
	self assert: steps first status equals: 'SUCCESS'.
	self assert: steps first durationText isEmpty not.
	self assert: steps second gtDisplayString equals: 'Shell Script'.
	self assert: steps second parameterDescription equals: ''.
	self
		assert: steps second resultBackgroundColor
		equals: BrGlamorousColors errorBackgroundColor.
	self assert: stage steps == steps.
	self assert: requests equals: 1.
	^ stage
]

{ #category : #examples }
JcCoreModelExamples >> stageWithoutStepData [
	<gtExample>
	<return: #JcCoreStage>
	| client run stage requests |
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
					yourself).
	stage := JcCoreStage
			run: run
			parent: nil
			rawData: (Dictionary new
					at: 'id' put: '3';
					at: 'name' put: 'Parallel';
					yourself).
	self assert: stage steps isEmpty.
	self assert: stage steps isEmpty.
	self assert: requests equals: 1.
	^ stage
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

{ #category : #examples }
JcCoreModelExamples >> stepWithLog [
	<gtExample>
	<return: #JcCoreStep>
	| client run stage step requests |
	requests := 0.
	client := JcCoreClient new.
	client baseUrl: 'https://jenkins.example/'.
	client
		responseProvider: [ :url | 
			requests := requests + 1.
			self
				assert: url asString
				equals: 'https://jenkins.example/job/main/7/execution/node/13/wfapi/log'.
			'{"nodeId":"13","length":30,"hasMore":false,"text":"<span class=\"pipeline-new-node\">[Pipeline] sh</span>\n+ echo &lt;ok&gt; &amp; done\n"}' ].
	run := JcCoreRun
			client: client
			jobNames: #('main')
			rawData: (Dictionary new
					at: 'number' put: 7;
					yourself).
	stage := JcCoreStage
			run: run
			parent: nil
			rawData: Dictionary new.
	step := JcCoreStep
			stage: stage
			rawData: (Dictionary new
					at: 'id' put: '13';
					at: 'name' put: 'Shell Script';
					yourself).
	self
		assert: step logText
		equals: '[Pipeline] sh' , String lf , '+ echo <ok> & done' , String lf.
	self assert: step logText == step logText.
	self assert: requests equals: 1.
	^ step
]

{ #category : #examples }
JcCoreModelExamples >> stepWithoutLog [
	<gtExample>
	<return: #JcCoreStep>
	| client run stage step requests |
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
					yourself).
	stage := JcCoreStage
			run: run
			parent: nil
			rawData: Dictionary new.
	step := JcCoreStep
			stage: stage
			rawData: (Dictionary new
					at: 'id' put: '13';
					yourself).
	self assert: step logText equals: ''.
	self assert: step logText equals: ''.
	self assert: requests equals: 1.
	^ step
]

{ #category : #examples }
JcCoreModelExamples >> testCaseDetailsLoadedLazily [
	<gtExample>
	<return: #JcCoreRun>
	| log run cases |
	log := OrderedCollection new.
	run := self reportRunLoggingTo: log.
	cases := run problematicTests.
	self assert: log size equals: 1.
	self assert: cases first errorDetails equals: 'boom'.
	self assert: cases first errorStackTrace equals: 'DemoExamples>>fails'.
	self assert: cases second skippedMessage equals: 'not now'.
	self assert: cases second errorDetails equals: ''.
	self assert: log size equals: 2.
	self assert: cases third errorDetails equals: 'boom on linux'.
	self assert: cases third errorDetails equals: 'boom on linux'.
	self assert: log size equals: 3.
	^ run
]

{ #category : #examples }
JcCoreModelExamples >> testCaseScripterArtifacts [
	<gtExample>
	<return: #JcCoreRun>
	| run cases |
	run := self reportRunLoggingTo: OrderedCollection new.
	cases := run problematicTests.
	self
		assert: (cases first scripterArtifacts collect: #name) asArray
		equals: #('step.png' 'step-events-all.txt').
	self
		assert: (cases first scripterArtifacts
				allSatisfy: [ :each | each platformName = 'arm-x' ]).
	self assert: cases second scripterArtifacts isEmpty.
	self assert: cases third scripterArtifacts size equals: 1.
	self assert: cases third scripterArtifacts first platformName equals: 'lin-x'.
	self assert: run scripterArtifacts size equals: 4.
	^ run
]

{ #category : #examples }
JcCoreModelExamples >> testCaseStatusIconScripter [
	<gtExample>
	<return: #BlScripter>
	| scripter case |
	case := self buildWithTestCases problematicTests second.
	scripter := BlScripter new.
	scripter element: case statusIcon.
	self
		assert: scripter element background paint color
		equals: BrGlamorousColors failureBackgroundColor.
	self
		assert: case resultBackgroundColor
		equals: BrGlamorousColors failureBackgroundColor.
	^ scripter
]

{ #category : #examples }
JcCoreModelExamples >> testCaseViews [
	<gtExample>
	<return: #JcCoreRun>
	| run case stage |
	run := self reportRunLoggingTo: OrderedCollection new.
	case := run problematicTests first.
	stage := run stages detect: [ :each | each name = 'Test Mac' ].
	{run gtProblematicTestsFor: GtPhlowView empty.
		run gtScripterArtifactsFor: GtPhlowView empty.
		stage gtProblematicTestsFor: GtPhlowView empty.
		stage gtArtifactsFor: GtPhlowView empty.
		case gtErrorDetailsFor: GtPhlowView empty.
		case gtTestFor: GtPhlowView empty.
		case gtArtifactsFor: GtPhlowView empty.
		case gtScreenshotsFor: GtPhlowView empty}
		do: [ :view | self assert: (view asElementDo: [ :each | each ]) notNil ].
	^ run
]

{ #category : #examples }
JcCoreModelExamples >> testCaseWithoutReport [
	<gtExample>
	<return: #JcCoreRun>
	| run |
	run := self buildWithoutTestReport.
	self assert: run problematicTests isEmpty.
	self
		assert: (JcCoreStage
				run: run
				parent: nil
				rawData: (Dictionary new
						at: 'name' put: 'Test';
						yourself)) testCases isEmpty.
	^ run
]
