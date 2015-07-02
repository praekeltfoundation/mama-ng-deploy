FROM python:2.7.9
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

RUN pip install 'vumi-http-api>=0.1.0'

COPY . /app
WORKDIR /app

CMD twistd -n --pidfile=vumi-http-api.pid \
    vumi_worker \
    --worker-class=vumi_http_api.VumiApiWorker \
    --hostname=rabbitmq --vhost=/ --username=guest --password=guest \
    --config=vumi_http_api.yaml --set-option=transport_name:$TRANSPORT \
    --set-option=push_message_url:$PUSH_MSG_URL \
    --set-option=push_event_url:$PUSH_EVENT_URL
