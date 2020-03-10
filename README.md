## A Gt style Jenkins client.
```
EpMonitor current disable.
[ 
  Metacello new
    baseline: 'JenkinsClient';
    repository: 'github://feenkcom/jenkins-client/src';
    load
] ensure: [ EpMonitor current enable ].
```
