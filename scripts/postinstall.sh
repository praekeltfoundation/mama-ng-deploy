#!/bin/bash

# # Exit on errors from here.
set -e

docker build -t praekelt/mama-ng-vxfreeswitch $INSTALLDIR/$REPO/docker-vms/vxfreeswitch
docker build -t praekelt/mama-ng-vxtwinio $INSTALLDIR/$REPO/docker-vms/vxtwinio
