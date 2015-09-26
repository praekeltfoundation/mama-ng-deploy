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

The app containers are defined in [docker-compose.yml](docker-compose.yml).
Additional configuration is supplied via environment files that are deployed
from the puppet `mama_nigeria_app` module.

Each environment file is defined by a template of default values, plus values
that differ between deployments and that are added for each machine.

There three separate environment files, along with their configurable
environment variables, are:

* `mama_ng_contentstore.env` - environment variables for the content store
  Django application. This application holds voice and text messages for
  sending to people who register for stage-based messaging.

  * `VIRTUAL_HOST` - content store host name, e.g.
    `mama-ng-contentstore.example.com`.

  * `SECRET_KEY` - Django secret key.

  * `MAMA_NG_CONTENTSTORE_SENTRY_DSN` - Sentry DSN.

* `mama_ng_control.env` - environment variables for the control interface
  Django application.

  * `VIRTUAL_HOST` - control interface host name, e.g.
    `mama-ng-control.example.com`.

  * `SECRET_KEY` - Django secret key.

  * `MAMA_NG_CONTROL_SENTRY_DSN` - Sentry DSN.

  * `MAMA_NG_CONTROL_URL` - URL of the content store API, e.g.
    `http://mama-ng-control.example.com/api/v1`.

  * `MAMA_NG_CONTROL_VUMI_API_URL` - URL of the Vumi HTTP API for sending
    messages, e.g. `http://mama-ng-infr.example.com/api/vumi_http`.

  * `MAMA_NG_CONTROL_VUMI_ACCOUNT_KEY` - account key for the above API.

  * `MAMA_NG_CONTROL_VUMI_CONVERSATION_KEY` - conversation key for the above
    API.

  * `MAMA_NG_CONTROL_VUMI_ACCOUNT_TOKEN` - authentication token for the above
    API.

  * `MAMA_NG_CONTROL_CONTENTSTORE_API_URL` - URL of the content store API, e.g.
    `http://mama-ng-contentstore.example.com/contentstore`.

  * `MAMA_NG_CONTROL_CONTENTSTORE_AUTH_TOKEN` - authentication token for the
    above API.

  * `MAMA_NG_CONTROL_SCHEDULER_URL` - URL of the scheduler API, e.g.
    `http://mama-ng-scheduler.example.com/mama-ng-scheduler/rest`.

* `mama_ng_scheduler.env` - environment variables for the **Grails** scheduler
  application.

  * `VIRTUAL_HOST` - scheduler host name, e.g. `mama-ng-scheduler.example.com`.

  * `SENTRY_URL` - Sentry DSN.

Each application also has its own database container and volume and
`mama_ng_control` also has celery and redis containers for task management.


Containers on infr
------------------

XXX


Gotchas
-------

XXX
