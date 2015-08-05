FROM python:2.7.9
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

RUN apt-get update && apt-get install -y nodejs npm

RUN pip install 'vxsandbox>=0.5.3'

RUN npm install moment url querystring crypto lodash q jed vumigo_v01 vumigo_v02 go-jsbox-location go-jsbox-metrics-helper go-jsbox-ona go-jsbox-xform

COPY . /app
WORKDIR /app

CMD twistd -n --pidfile=jssandbox.pid \
    vumi_worker --worker-class=vxsandbox.worker.StandaloneJsFileSandbox \
    --hostname=rabbitmq --vhost=/ --username=guest --password=guest \
    --config=jssandbox.yaml --set-option=transport_name:$TRANSPORT_NAME \
    --set-option=executable:`which nodejs`
