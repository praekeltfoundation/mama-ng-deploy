FROM ubuntu
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

EXPOSE 8000

COPY . /app
WORKDIR /app

RUN pip install vxfreeswitch

CMD [ \
    "twistd", "-n", "--pidfile=vxfreeswitch.pid", \
    "vumi_worker", "--worker-class=vxfreeswitch.VoiceServerTransport", \
    "--config=vxfreeswitch.yaml", \
    "--set-option=freeswitch_auth:$FREESWITCH_AUTH" \
]
