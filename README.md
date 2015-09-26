mama-ng-deploy
==============

A package to tie together and deploy the components of MAMA Nigeria.

MAMA Nigeria is deployed to a pair of machines:

* `-app` which hosts the scheduler, content store and control interface.

* `-infr` which hosts Freeswitch, the Vumi transports, the Vumi javascript
  sandbox applications, Graphite and Grafana.

Sideloader is used to deploy packages to each machine:

* `-app` has the packages `mama-ng-deploy`, `mama-ng-control`,
  `mama-ng-contentstore` and `mama-ng-scheduler` installed.

* `-infr` has just `mama-ng-deploy`.

The launching and building of docker containers after package installation
is different for the two machines:

* on `-app`, containers are manually rebuilt by running
  `sudo docker-compose build` and supervisord runs `docker-compose up`.

* on `-infr`, containers are rebuilt by the `mama-ng-deploy` post-install
  script and supervisord launches each container separately using
  `mama-ng-deploy/scripts/docker-run.sh`.

Containers on app
-----------------

XXX


Containers on infr
------------------

XXX
