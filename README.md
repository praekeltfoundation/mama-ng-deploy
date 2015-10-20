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

When creating a completely new environment, some setup steps are needed to
ensure that database are populated with the necessary tables:

```
  $ source /var/praekelt/python/bin/activate
  $ cd /var/praekelt/mama-ng-deploy
  $ sudo docker-compose build
  $ sudo docker-compose up -d mamangscheduler
  $ sudo docker-compose run mamangcontentstore /usr/local/bin/python manage.py migrate
  $ sudo docker-compose run mamangcontentstore /usr/local/bin/python manage.py createsuperuser
  $ sudo docker-compose run mamangcontentstore /usr/local/bin/python manage.py collectstatic
  $ sudo docker-compose run mamangcontrol /usr/local/bin/python manage.py migrate
  $ sudo docker-compose run mamangcontrol /usr/local/bin/python manage.py createsuperuser
  # Connect to the scheduler postgres database and create an admin user with password admin.
  $ psql -h 172.17.42.1 -p 5434 -U postgres
  postgres=# insert into service_users (id, version, date_created, password_hash, username, type) values (1, 0, NOW(), 'YWRtaW4=', 'admin', 'SUPER');
```


Containers on infr
------------------

The `-infr` containers are defined in folders under [docker-vms](docker-vms).
Container instances are configured in puppet and launched directly via
supervisord.

In some cases (voice transports and Javascripts sandbox applications) multiple
instances of the same container definition are launched with different
configuration options.

QA and production environments can vary quite a bit, mostly because the
Vumi transport configurations needed for voice and SMS vary quite
substantially. There is a puppet module per-environment that contains
FreeSwitch and transport configuration files for the given environment.

Container configurations used by `-infr`:

* `mama-ng-redis` - the Redis server used by all Vumi workers.

  * `volume: /data` - volume that holds the redis data dumps.

* `mama-ng-rabbitmq` - the RabbitMQ server used by all Vumi workers.

  * `RABBITMQ_NODENAME` - the node name for the RabbitMQ server, e.g.
    `mama-ng-rabbitmq`.

* `freeswitch` - the FreeSwitch server used by all voice transport workers.
  This needs to link to both `redis` and `rabbitmq` containers because the
  voice transports need access to them and have to be on the same network
  as the FreeSwitch container so that FreeSwitch and the voice transports
  can both establish TCP connections to each other (this seems to be the
  only simple way to provider bi-directional TCP access in Docker).

  * `-p 16384-16394:16384-16394/udp` - this opens up ports for SIP UDP
    connections. Ideally we'd open up a lot more ports for production to allow
    many concurrent voice calls, but Docker uses ~10MB of RAM per-port, which
    makes opening hundreds of ports an issue.

* `vxfreeswitch_<line_name>` - a Vumi voice transport worker. There is one
  per voice line, but they all connect to the same FreeSwitch instance and
  share the same container image, `mama-ng-vxfreeswitch`.

  * `--net container:freeswitch` -- voice transports and FreeSwitch both need
    to be able to establish TCP connections to each other, so they share the
    same docker network.

  * `CONFIG_FILE` - the Vumi worker YAML config file for this transport, e.g.
    `vxfreeswitch_app_1.yaml`.

* `jssandbox_<app_name>` - a Vumi Javasript sandbox application worker. There
   is one per Javasacript sandbox application, but they all share the same
   container image, `mama-ng-jssandbox`. Usually there is also a one-to-one
   correspondence between applications and voice lines and
   `<line_name>` and `<app_name>` are the same for each (see
   `vxfreeswitch_<line_name>` above, although not all applications are
   Javascript sandbox workers).

  * links to `redis` and `rabbitmq` containers.

  * `volume: /app/app.js` - the Javascript application to run inside this
    worker.

  * `volume: /app/config.json` - the Javasript application config.

  * `TRANSPORT_NAME` - the name of the Vumi transport to send and receive
    messages from via RabbitMQ. It should match the transport name of one
    of the Vumi transports.

* `vumi_api` - a Vumi HTTP API application worker. The MAMA Nigeria control
  interface Django application uses this to initiate outbound voice calls.

  * links to `redis` and `rabbitmq` containers.

  * exposes port `9003` and listens for HTTP API requests there.

  * `TRANSPORT` - the name of the Vumi transport to send and receive messages
    from via RabbitMQ. It should match the transport name of one of the Vumi
    transports.

  * `PUSH_MSG_URL` - the URL to POST inbound messages to, e.g.
    `http://username:passwd@mama-ng-control.example.com/api/v1/messages/inbound/`.

  * `PUSH_EVENT_URL` - the URL to POST events for outbound messages to, e.g.
    `http://mama-ng-control.prd.praekelt.com/api/v1/messages/events`.

  * `CONVERSATION` - the uuid of the conversation messages are from. Should
    match the conversation key specified for the control interface.

* `metrics_graphite` - runs Graphite web API and carbon metrics receivers.

  * links to `rabbitmq` (for receiving metrics from Vumi workers).

  * `volume: /opt/graphite/storage` - where Graphite metrics are stored.

  * `volume: /opt/graphite/webapp/graphite.db` - Graphite SQLite database.

* `metrics_grafana` - runs the Grafana metrics web interface.

  * links to `metrics_graphite`

  * `volume: /var/lib/grafana` - Grafana's database and configuration.

* `metrics_vumi_workers` - runs Vumi's metric collectors and aggregators.
  Pushes metrics to Graphite via RabbitMQ.

  * links to `rabbitmq`

* `metrics_api` - runs Vumi's metrics API which allows retrieving metrics
  from Graphite and firing metrics to Graphite (via Vumi's metrics workers).

  * links to `rabbitmq` (for firing metrics) and `metrics_graphite` (for
    reading metrics from Graphite's web UI).

  * exposes port `8000` (the metris HTTP API).

* `smpp_<line_name>` - run a Vumi SMPP transport. There may be multiple
  instances of these but they all use the `mama-ng-smpp` container image.

  * links to `rabbitmq` and `redis`.

  * `SMPP_USERNAME` - SMPP system id to use when connecting.

  * `SMPP_PASSWORD` - SMPP password to use when connecting.

  * `SMPP_ENDPOINT` - SMPP host and port to connect to as a Twisted endpoint,
    e.g. `tcp:host=smpp.example.com:port=2345`.


Gotchas
-------

Unexpected rough edges:

* We still need to figure out how to properly configure the Grafana base URL.

* We still need to figure out how to configure Graphite as a Grafan source.

* We still need to figure out how to setup an example Grafana dashboard that
  a least shows that metrics are working.
