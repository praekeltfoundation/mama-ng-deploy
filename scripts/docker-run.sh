#!/bin/bash -e
#
# Run a docker container after cleaning up any existing container with the same name
# 
# Usage:
#   docker-run.sh <name> [<extra-docker-run-argument> ...]
#
# Example:
#   docker-run.sh my-container --link redis:redis -p 8080:8080 group/container-type

USAGE="Usage: $0 <name> [<extra-docker-run-argument> ...]"
if [ "$#" == "0" ]; then
    echo "$USAGE"
    exit 1
fi

CONTAINER_NAME="$1"
shift

docker rm -f "$CONTAINER_NAME" || true
docker run --rm --name="$CONTAINER_NAME" "$@"
