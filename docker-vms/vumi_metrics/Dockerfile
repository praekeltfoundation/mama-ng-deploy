FROM python:2.7.9
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

# Install vumi
RUN pip install supervisor
RUN pip install 'vumi>=0.5.21'

# Configure
COPY config/supervisor/ /etc/supervisor/conf.d/

COPY . /app
WORKDIR /app

CMD /usr/local/bin/supervisord -c /etc/supervisor/conf.d/vumi_metrics.conf
