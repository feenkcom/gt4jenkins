# Gt style Jenkins client.
```
EpMonitor current disable.
[ 
  Metacello new
    baseline: 'GToolkit4Jenkins';
    repository: 'github://feenkcom/gt4jenkins/src';
    load
] ensure: [ EpMonitor current enable ].
```
