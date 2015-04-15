FROM python:2.7.9
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

EXPOSE 8000

RUN pip install vxtwinio

COPY . /app
WORKDIR /app

CMD [ \
    "twistd", "-n", "--pidfile=vxtwinio.pid", \
    "vumi_worker", "--worker-class=vxtwinio.TwilioAPIWorker", \
    "--hostname=rabbitmq", \
    "--config=vxtwinio.yaml" \
]
