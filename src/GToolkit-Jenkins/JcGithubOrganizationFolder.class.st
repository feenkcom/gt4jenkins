Class {
	#name : 'JcGithubOrganizationFolder',
	#superclass : 'JcModelElement',
	#category : 'GToolkit-Jenkins-Generated-IoJenkinsBlueoceanBlueocean_github_pipeline'
}

{ #category : 'accessing' }
JcGithubOrganizationFolder >> gtPipelinesFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Pipelines' translated;
		priority: 10;
		items: [ self pipelines ];
		column: 'Name' translated text: [ :p | p rawData at: 'name' ]
]

{ #category : 'accessing' }
JcGithubOrganizationFolder >> pipelines [
	^ (super linksClientFor: 'pipelines') execute
]
