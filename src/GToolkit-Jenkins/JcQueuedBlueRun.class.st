Class {
	#name : #JcQueuedBlueRun,
	#superclass : #JcModelElement,
	#instVars : [
		'parentBranchName',
		'tests'
	],
	#category : #'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanServiceEmbeddedRest'
}

{ #category : #accessing }
JcQueuedBlueRun >> allTests [
	|client|
	client := (super urlClientFor: self allTestsURL).
	client modelBuilder jenkinsClient setBasicAuth.
	^ client execute
 
]

{ #category : #accessing }
JcQueuedBlueRun >> allTestsURL [
		^ '/job/', (parentBranchName copyReplaceAll: '/' with: '/job/'), '/' , (rawData at: 'id'), '/testReport/api/json'
]

{ #category : #accessing }
JcQueuedBlueRun >> duration [
	((rawData at: 'result') = 'UNKNOWN') ifTrue: [^ (rawData at: 'state')].
	^ (rawData at: 'durationInMillis')  asNumber milliSeconds
]

{ #category : #accessing }
JcQueuedBlueRun >> gtDisplayOn: stream [
	stream nextPutAll: (rawData at: 'id')
]

{ #category : #accessing }
JcQueuedBlueRun >> gtNodesFor: aView [
	<gtView>
	| aList |

	aList := aView columnedList
		title: 'Nodes' translated;
		priority: 60;
		items: [ self nodes].

	aList column
		title: 'Index' translated;
		width: 30;
		item: [ :eachItem :eachIndex | eachIndex asRopedText foreground: Color gray].
	
	aList column
		title: 'Item' translated;
		item: [ :eachItem :eachIndex | eachItem ];
		itemFormat: [ :eachItem | eachItem gtDisplayText ].
	
	^ aList
]

{ #category : #accessing }
JcQueuedBlueRun >> gtStagesMapFor: aView [
	<gtView> 
	^ aView mondrian 
	  title: 'Stages Map' translated;
	  priority: 55; 
	  painting: [ :mondrian | 
	  	  |allNodes|
	  	  allNodes := self nodes.
			mondrian nodes 
				shape: [ :aStage | 
				|container editor statusColor aDropdown|
					statusColor := aStage resultBackgroundColor.
					container := BlElement new
						layout: BlLinearLayout horizontal;
						look:BrShadowLook;
						clipChildren: false;
						margin:(BlInsets all:10);
						background: Color white;
						zIndex: 1;
						when: BlClickEvent do:[:e | e target phlow spawnObject: aStage];
						constraintsDo: [ :c |
							c horizontal exact:200.
							c vertical fitContent].
					editor := BrLabel new 
						text: aStage name asRopedText;
						look: BrGlamorousLabelLook;
						constraintsDo: [ :c | 
							c margin: (BlInsets all: 5).
							c vertical fitContent.
							c horizontal matchParent.
							 ].
					aDropdown := BrBadge new
							label: (aStage failedTests size);
							exact: 20 @ 20;
							visibility:
					(aStage failedTests size isZero
						ifTrue: [ BlVisibility gone ]
						ifFalse: [ BlVisibility visible ]);
					constraintsDo: [ :c | 
						c horizontal fitContent.
						c vertical fitContent.
						c ignoreByLayout.
						c ignored horizontal alignRight.
						c ignored vertical alignTop.
						c margin: (BlInsets top: -10 right: -10) ];
					look: BrGlamorousBadgeWithLabelLook +
						(BrGlamorousWithDropdownLook
							handle: [ BrBadge new
										label: (aStage failedTests size);
										exact: 20 @ 20;
										look: BrGlamorousBadgeWithLabelLook;
										yourself ]
							content: [ | aPhlowView aPopupElement |
								aPhlowView := aStage gtFailedTestsFor: GtPhlowEmptyView new.
								aPopupElement := BlElement new
											border: (BlBorder paint: Color orange width: 2);
											background: Color white;
											layout: BlLinearLayout vertical;
											constraintsDo: [ :c | 
												c horizontal fitContent.
												c vertical fitContent ].
								aPhlowView asElementDo: [ :anElement | 
												anElement layout: BlLinearLayout vertical.
												aPopupElement addChild: anElement.
												anElement 
													when: GtPhlowObjectToSpawn do: [:e | 
													container fireEvent: (GtPhlowObjectToSpawn new object: e object; sourceElement: e target)] ].
										aPopupElement ]).
					container
						addChild: (BrVerticalPane new vMatchParent; hExact: 15; background: statusColor );
						addChild: aDropdown;
						addChild: (editor).
				];
				
			with: allNodes.
			mondrian edges
				shape: [
					BlSigmoidElement new 
						zIndex: 0;
						beVertical;
						bendingPoint:0.3;
						sharpness: 0.1;
						border: (BlBorder paint: (Color gray alpha: 0.2) width: 2)];
				fromCenterBottom;
				toCenterTop;
				connectFrom: #yourself 
				toAll: [:each | | pN |
					pN := each nextStagesIds.
					allNodes select: [ :node | pN anySatisfy: [ :stageID | stageID = node id ] ] ].
			mondrian layout custom: ((GtGradNorthHierarchicalLayout new interRanksSpacing: 30)).
			]

]

{ #category : #accessing }
JcQueuedBlueRun >> gtTestsFor: aView [
	<gtView>
	((rawData at: 'state') = 'RUNNING') ifTrue: [^ aView empty].
	^ aView columnedList
		title: (rawData at: 'runSummary') translated;
		priority: 50;
		items: [ self tests];
		column: 'Status' translated 
			icon: [ :each | BlElement new 
				geometry: BlCircle new; 
				background: each statusBackgroundColor; 
				size: 10@10 ]
			width: 50;
		column: 'Status' translated format: [ :eachTest | eachTest status ] width: 70;
		column: 'Class' translated format: [ :eachTest | eachTest testClassName ] width: 250;
		column: 'Method' translated format: [ :eachTest | eachTest testMethodName ];
		column: 'Stage' translated format: [:eachTest | eachTest fullStageName ]
]

{ #category : #accessing }
JcQueuedBlueRun >> nodes [
	^ ((super linksClientFor: 'nodes') execute) collect: [:each | each parentRun: self]
]

{ #category : #accessing }
JcQueuedBlueRun >> parentBranchName: aName [
	parentBranchName := aName
]

{ #category : #accessing }
JcQueuedBlueRun >> result [
	^ rawData at: 'result'
]

{ #category : #accessing }
JcQueuedBlueRun >> resultBackgroundColor [
	^ JcJenkinsClient backgroundColorForStatus: self result
]

{ #category : #accessing }
JcQueuedBlueRun >> startTime [
	^ (rawData at: 'state')
]

{ #category : #accessing }
JcQueuedBlueRun >> tests [
	^ ((super linksClientFor: 'tests') execute).
]
