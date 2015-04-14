FROM ubuntu
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

RUN pip install vxtwinio
CMD ["twistd", "-n", "--pidfile=vxtwinio.pid", "vumi_worker", "--worker-class=vxtwinio.TwilioAPIWorker"]
