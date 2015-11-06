FROM python:2.7.9
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

RUN pip install 'vumi>=0.5.19'

COPY . /app
WORKDIR /app

CMD twistd -n --pidfile=static_reply_app.pid \
    vumi_worker \
    --worker-class=vumi.demos.static_reply.StaticReplyApplication \
    --hostname=rabbitmq.service.consul --vhost=/ --username=guest --password=guest \
    --config=static_reply_app.yaml --set-option=transport_name:$TRANSPORT_NAME
