Class {
	#name : #JcWorkflowRun,
	#superclass : #JcModelElement,
	#instVars : [
		'allTests',
		'consoleText',
		'rawWfApiData'
	],
	#category : #'GToolkit-Jenkins-Generated-OrgJenkinsciPluginsWorkflowJob'
}

{ #category : #accessing }
JcWorkflowRun >> allTests [
	|client stageId allTestsResult|
	allTests ifNil: [
		client := (super fullUrlClientFor: self allTestsURL).
		client modelBuilder jenkinsClient setBasicAuth.
		allTestsResult := client execute].
		
		allTestsResult ifNotNil: [
			allTests := Dictionary new.
			allTestsResult rawSuites collect: [ :suite | 
				|enclosingBlocksArray|
				enclosingBlocksArray := (suite at: 'enclosingBlocks').
				enclosingBlocksArray ifNotEmpty: [
					stageId := enclosingBlocksArray first.
					allTests at: stageId ifAbsentPut: OrderedCollection new.
						(allTests at: stageId) add: suite]]].
	^ allTests.
]

{ #category : #accessing }
JcWorkflowRun >> allTestsFlattened [
	^ self allTests flatCollect: [:e | super modelBuilder modelFrom: (e value) className: 'IoJenkinsBlueoceanServiceEmbeddedRestJunit.BlueJUnitStageTestResult' ]
]

{ #category : #accessing }
JcWorkflowRun >> allTestsURL [
		^ (rawData at: 'url'), '/testReport/api/json'
]

{ #category : #accessing }
JcWorkflowRun >> getLogText [
	|text logURL|
	consoleText ifNil: [
	logURL := (rawData at:'url'),'/consoleText' .
	text := (super fullUrlClientFor: logURL) getRawData.
	text ifNil: [^nil].
	text := text copyReplaceAll: (Character value:27) asString with:  String cr.
	
	consoleText := text].
	^ consoleText
]

{ #category : #accessing }
JcWorkflowRun >> gtAllTestsFor: aView [
	<gtView>
	| at|
	at := self allTestsFlattened.
	at isEmpty ifTrue:[ ^ aView empty].
	^ aView columnedList
		title: 'All Examples' translated;
		priority: 60;
		items: [ at];
		column: 'Index' translated item: [ :eachItem :eachIndex | eachIndex asRopedText foreground: Color gray] width: 20;
		column: 'Status' translated 
			icon: [ :each | BlElement new 
				geometry: BlCircle new; 
				background: each statusBackgroundColor; 
				size: 10@10 ]
			width: 50;
		column: 'Package' translated format: [ :eachItem | eachItem testClassName] width: 250;
		column: 'Examples' translated format: [ :eachItem | eachItem allCases size] width: 50
]

{ #category : #accessing }
JcWorkflowRun >> gtDisplayOn: stream [
	stream nextPutAll: (rawData at: 'id')
]

{ #category : #accessing }
JcWorkflowRun >> gtLogFor: aView [
	<gtView>
	|text logURL|
	text := self getLogText.
	text ifNil: [^aView empty].
	^ aView textEditor
		aptitude: BrGlamorousCodeEditorAptitude;
		styler: JcConsoleStyler new;
		title: 'Console Log';
		text: [text]
]

{ #category : #accessing }
JcWorkflowRun >> gtStagesFor: aView [
	<gtView>
	| at|
	at := self wfapiModel stages.
	at isEmpty ifTrue:[ ^ aView empty].
	^ aView columnedList
		title: 'Stages' translated;
		priority: 60;
		items: [ at];
		column: 'Index' translated 
			item: [ :eachItem :eachIndex | 
				eachIndex asRopedText foreground: Color gray] 
			width: 20;
		column: 'Status' translated 
			icon: [ :each | BlElement new 
				geometry: BlCircle new; 
				background: each resultBackgroundColor; 
				size: 10@10 ]
			width: 50;
		column: 'Name' translated format: [ :eachItem | eachItem gtDisplayText] width: 250
		
]

{ #category : #accessing }
JcWorkflowRun >> result [
	^ rawData at: 'result'
]

{ #category : #accessing }
JcWorkflowRun >> resultBackgroundColor [
	^ JcJenkinsClient backgroundColorForStatus: self result
]

{ #category : #accessing }
JcWorkflowRun >> startTime [
	|st|
	st := DateAndTime fromSeconds: ((rawData at: 'timestamp') / 1000 ).
	^ st
	
]

{ #category : #accessing }
JcWorkflowRun >> wfapi [
	|client|
	rawWfApiData ifNil: [
	client := (super fullUrlClientFor: ((rawData at: 'url'), '/wfapi/describe')).
	rawWfApiData := client getRawData].
	^ NeoJSONReader fromString:rawWfApiData
]

{ #category : #accessing }
JcWorkflowRun >> wfapiModel [
	^ self modelBuilder modelFrom: self wfapi className:'IoJenkinsWfapi.WfWorkflowRun'. 
]
