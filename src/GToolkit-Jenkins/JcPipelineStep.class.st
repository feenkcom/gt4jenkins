Class {
	#name : #JcPipelineStep,
	#superclass : #JcModelElement,
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanRestImplPipeline'
}

{ #category : #accessing }
JcPipelineStep >> getLogText [
	|text logURL|
	logURL := ((((rawData at:'actions') detect: ([:a | (a at:'urlName') = 'log'])) at: '_links') at: 'self') at: 'href'.
	(logURL includesSubstring: 'start=')
		ifFalse: [ 
			logURL := logURL allButLast, '?start=0' ].
	text := (super urlClientFor: logURL) getRawData.
	text ifNil: [^nil].
	text := text copyReplaceAll: (Character value:27) asString with: ''.
	^ text
]

{ #category : #'gt - extensions' }
JcPipelineStep >> gtActionParseLoadingLogFor: anAction [
	<gtAction>
	| displayDescription |
	
	rawData ifNil: [ ^ anAction noAction ].
	displayDescription := (rawData at: 'displayDescription').
	displayDescription ifNil: [ ^ anAction noAction ].
	(displayDescription includesSubstring: 'gt-releaser release-build --loader cloner') ifFalse: [
		^ anAction noAction ].
	
	^ anAction dropdown
		tooltip: 'Parse the loading logs';
		priority: 11;
		label: 'Loading Log';
		icon: BrGlamorousVectorIcons playinspect;
		content: [ :aButton | 
			| actions |
			actions := OrderedCollection new.
			actions add: ('Cloner' -> [ :anElement | 
				anElement phlow spawnObject: (GtRlClonerBaselineEvent 
					fromContents: self getLogText).
				aButton dispatchEvent: BrDropdownHideWish new ]).
			actions add: ('Loader' -> [ :anElement | 
				anElement phlow spawnObject: (GtRlLoaderEventsGroup 
					fromContents: self getLogText).
				aButton dispatchEvent: BrDropdownHideWish new ]).
			actions add: ('Consolidated' -> [ :anElement | 
				anElement phlow spawnObject: (GtRlLoadedConsolidatedBaselineEvent 
					fromContents: self getLogText).
				aButton dispatchEvent: BrDropdownHideWish new ]).
			BrGlamorousSimpleContextMenuContent new
				items:actions;
				yourself]
]

{ #category : #'gt - extensions' }
JcPipelineStep >> gtActionParseReleaserLogFor: anAction [
	<gtAction>
	| displayDescription |
	
	rawData ifNil: [ ^ anAction noAction ].
	displayDescription := (rawData at: 'displayDescription').
	displayDescription ifNil: [ ^ anAction noAction ].
	(displayDescription includesSubstring: 'gt-releaser run-releaser') ifFalse: [
		^ anAction noAction ].
	
	^ anAction button
		tooltip: 'Parse releaser logs';
		priority: 11;
		label: 'Releaser Log';
		icon: BrGlamorousVectorIcons playinspect;
		action: [ :aButton | 
			aButton phlow spawnObject: (GtRlReleaserSignalsLogReader 
				readFrom:  self getLogText readStream) ]
]

{ #category : #'gt - extensions' }
JcPipelineStep >> gtActionParseVirtualMachineStatisticsFor: anAction [
	<gtAction>
	| displayDescription |
	rawData ifNil: [ ^ anAction noAction ].
	displayDescription := rawData at: 'displayDescription'.
	displayDescription ifNil: [ ^ anAction noAction ].
	(displayDescription includesSubstring: 'gt-examples test')
		ifFalse: [ ^ anAction noAction ].

	^ anAction button
		tooltip: 'Parse virtual machine statistics';
		priority: 11;
		label: 'VM Statistics';
		icon: BrGlamorousVectorIcons playinspect;
		action: [ :aButton | aButton phlow 
			spawnObject: self gtVmExecutionStatisticsReports ]
]

{ #category : #accessing }
JcPipelineStep >> gtDisplayOn: stream [
	|displayDescription|
	displayDescription := (rawData at: 'displayDescription').
	displayDescription ifNil: [stream nextPutAll: (rawData at: 'displayName')].
	displayDescription ifNotNil: [stream nextPutAll: ('', displayDescription  )]
]

{ #category : #'gt - extensions' }
JcPipelineStep >> gtInstructionsFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Instructions';
		aptitude: BrGlamorousCodeEditorAptitude;
		text: [ self gtDisplayString ]
]

{ #category : #accessing }
JcPipelineStep >> gtLogFor: aView [
	<gtView>
	|text|
	text := self getLogText.
	text ifNil: [^aView empty].
	^ aView textEditor
		aptitude: BrGlamorousCodeEditorAptitude;
		styler: JcConsoleStyler new;
		title: 'Console log';
		text: [text]
]

{ #category : #'gt - extensions' }
JcPipelineStep >> gtVmExecutionStatisticsReports [
	^ GtVmExecutionStatisticsReportLogLoader
		readFromString: self getLogText readStream contents
]

{ #category : #testing }
JcPipelineStep >> isDisplayDescriptionMatching: aBlock [
	| displayDescription |
	
	displayDescription := (rawData at: 'displayDescription').
	displayDescription ifNil: [ ^ false ].
	^ aBlock value: displayDescription
]

{ #category : #testing }
JcPipelineStep >> isGtInstallerTestRun [
	^ self isDisplayDescriptionMatching: [ :aDescription |
		(aDescription includesSubstring: './gt-installer') and: [
			aDescription includesSubstring: 'gt-examples test' ] ]
]

{ #category : #accessing }
JcPipelineStep >> result [
	^ rawData at: 'result'
]

{ #category : #accessing }
JcPipelineStep >> resultBackgroundColor [
	^ JcJenkinsClient backgroundColorForStatus: self result
]
