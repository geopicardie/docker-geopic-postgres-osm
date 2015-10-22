FROM ubuntu:trusty
ENV DEBIAN_FRONTEND noninteractive
ENV OSM_PBF http://download.geofabrik.de/europe/france/picardie-latest.osm.pbf
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y locales && localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8
RUN apt-get install -y postgresql-9.3 postgresql-9.3-postgis-2.1 wget golang mercurial git build-essential libleveldb-dev libgeos-dev
RUN mkdir /tmp/src; cd /tmp/src;  git clone https://github.com/omniscale/imposm3 imposm3
RUN ln -s /usr/lib/libgeos_c.a /usr/lib/libgeos.a
RUN ln -s /usr/lib/libgeos_c.so /usr/lib/libgeos.so
ENV GOPATH /tmp
RUN cd /tmp/src; go get imposm3 ; go install imposm3
RUN cd /srv/; git clone https://github.com/bchartier/style-osm-geopicardie

ADD setup /usr/local/bin/setup
ADD run /usr/local/bin/run
ADD install_db /usr/local/bin/install_db
ADD install.sql /tmp/install.sql
ADD postgresql.conf /etc/postgresql/9.3/main/postgresql.conf
ADD pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf
RUN chown postgres /etc/postgresql/9.3/main/postgresql.conf
RUN chown postgres /etc/postgresql/9.3/main/pg_hba.conf
RUN mv /var/lib/postgresql /var/lib/postgresql_init
EXPOSE 5432
CMD ["/usr/local/bin/run"]
