FROM python:2.7.9
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

EXPOSE 8000

COPY . /app
WORKDIR /app

RUN pip install vxtwinio

CMD [ \
    "twistd", "-n", "--pidfile=vxtwinio.pid", \
    "vumi_worker", "--worker-class=vxtwinio.TwilioAPIWorker", \
    "--config=vxtwinio.yaml", \
]
