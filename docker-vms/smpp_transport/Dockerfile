FROM python:2.7.9
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

RUN pip install 'vumi>=0.5.19'

COPY . /app
WORKDIR /app

CMD twistd -n --pidfile=mtech_nigeria_smpp_transport.pid \
    vumi_worker \
    --worker-class=vumi.transports.smpp.SmppTransceiverTransport \
    --hostname=rabbitmq --vhost=/ --username=guest --password=guest \
    --config=mtech_nigeria_smpp_transport.yaml \
    --set-option=system_id:$SMPP_USERNAME \
    --set-option=password:$SMPP_PASSWORD \
    --set-option=twisted_endpoint:$SMPP_ENDPOINT
