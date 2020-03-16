# Gt style Jenkins client.
```
EpMonitor current disable.
[ 
  Metacello new
    baseline: 'JenkinsClient';
    repository: 'github://feenkcom/gt4jenkins/src';
    load
] ensure: [ EpMonitor current enable ].
```
