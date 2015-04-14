FROM ubuntu
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

RUN pip install vxfreeswitch
CMD ["twistd", "-n", "--pidfile=vxfreeswitch.pid", "vumi_worker", "--worker-class=vxfreeswitch.VoiceServerTransport"]
