FROM python:2.7.9
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

RUN pip install 'go-metrics-api>=0.1.4'

COPY . /app
WORKDIR /app

EXPOSE 8000

CMD twistd -n --pidfile=vumi-metrics-api.pid \
    cyclone \
    --listen=localhost \
    --port=8000 \
    --appopts=vumi_metrics_api.yaml \
    --app=go_metrics.server.MetricsApi
