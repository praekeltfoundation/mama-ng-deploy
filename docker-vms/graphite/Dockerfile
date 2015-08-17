FROM python:2.7.9
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

# Install graphite
RUN pip install whisper
RUN pip install carbon
RUN pip install django django-tagging
RUN pip install graphite-web
RUN pip install supervisor
RUN pip install gunicorn

# Configure
COPY config/supervisor/ /etc/supervisor/conf.d/
COPY config/graphite/ /opt/graphite/conf/
COPY config/graphite-web/ /opt/graphite/webapp/graphite/
RUN cp /opt/graphite/conf/graphite.wsgi.example /opt/graphite/webapp/wsgi.py

# Graphite database and whisper data volumes
VOLUME /opt/graphite/webapp/graphite.db
VOLUME /opt/graphite/storage

# Build initial database
WORKDIR /opt/graphite/conf
RUN python /opt/graphite/webapp/graphite/manage.py syncdb --noinput

# Setup server
EXPOSE 8080 2003
CMD /usr/local/bin/supervisord -c /etc/supervisor/conf.d/graphite.conf
