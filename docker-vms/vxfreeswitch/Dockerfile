FROM python:2.7.9
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

RUN pip install 'vxfreeswitch>=0.1.5'

COPY . /app
WORKDIR /app

CMD twistd -n --pidfile=vxfreeswitch.pid \
    vumi_worker --worker-class=vxfreeswitch.VoiceServerTransport \
    --hostname=rabbitmq --vhost=/ --username=guest --password=guest \
    --config=$CONFIG_FILE
