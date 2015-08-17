#!/bin/bash

# # Exit on errors from here.
set -e

docker build -t praekelt/mama-ng-vxfreeswitch $INSTALLDIR/$REPO/docker-vms/vxfreeswitch
docker build -t praekelt/mama-ng-redis $INSTALLDIR/$REPO/docker-vms/redis
docker build -t praekelt/mama-ng-rabbitmq $INSTALLDIR/$REPO/docker-vms/rabbitmq
docker build -t praekelt/mama-ng-freeswitch $INSTALLDIR/$REPO/docker-vms/freeswitch
docker build -t praekelt/mama-ng-smpp $INSTALLDIR/$REPO/docker-vms/smpp_transport
docker build -t praekelt/mama-ng-static-reply $INSTALLDIR/$REPO/docker-vms/static_reply_app
docker build -t praekelt/mama-ng-vumi-api $INSTALLDIR/$REPO/docker-vms/http_api
docker build -t praekelt/mama-ng-jssandbox $INSTALLDIR/$REPO/docker-vms/jssandbox
docker build -t praekelt/mama-ng-graphite $INSTALLDIR/$REPO/docker-vms/graphite
docker build -t praekelt/grafana $INSTALLDIR/$REPO/docker-vms/grafana
docker build -t praekelt/mama-ng-vumi-metrics $INSTALLDIR/$REPO/docker-vms/vumi_metrics
docker build -t praekelt/mama-ng-metrics-api $INSTALLDIR/$REPO/docker-vms/metrics_api
