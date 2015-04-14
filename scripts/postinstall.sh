#!/bin/bash

# # Exit on errors from here.
set -e

docker build -t praekelt/mama-ng-deploy $INSTALLDIR/$REPO
