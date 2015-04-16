FROM python:2.7.9
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

EXPOSE 8000

RUN pip install 'vxfreeswitch>=0.1.4'

COPY . /app
WORKDIR /app

CMD [ \
    "twistd", "-n", "--pidfile=vxfreeswitch.pid", \
    "vumi_worker", "--worker-class=vxfreeswitch.VoiceServerTransport", \
    "--hostname=rabbitmq", "--vhost=/", "--username=guest", "--password=guest", \
    "--config=vxfreeswitch.yaml", \
    "--set-option=freeswitch_auth:$FREESWITCH_AUTH" \
]
