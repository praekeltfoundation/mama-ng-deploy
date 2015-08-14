FROM debian:wheezy
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

# See http://docs.grafana.org/installation/debian/ for Grafana installation
# instructions and a layout of what is installed by the .deb.

RUN apt-get update
RUN apt-get install -y adduser libfontconfig curl

# RUN echo "deb https://packagecloud.io/grafana/testing/debian/ wheezy main" > /etc/apt/sources.list.d/grafana.list
# RUN wget https://packagecloud.io/gpg.key | apt-key add -
# RUN apt-get update
# RUN apt-get install -y grafana

RUN curl https://grafanarel.s3.amazonaws.com/builds/grafana_2.1.0_amd64.deb
RUN dpkg -i grafana_2.1.0_amd64.deb

VOLUME /var/log/grafana
VOLUME /var/lib/grafana

EXPOSE 3000

CMD /usr/sbin/grafana-server
