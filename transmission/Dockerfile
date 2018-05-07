FROM centos:7
MAINTAINER "Anonymous" <anon@coward>


ENV GOSU_VERSION 1.10
RUN set -ex; \
	\
	yum -y install epel-release; \
	yum install -y transmission-daemon sudo iproute python-pip python-devel gcc wget dpkg; \
	pip install --upgrade setuptools pip; \
	pip install shifter requests netifaces psutil; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /tmp/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
# verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /tmp/gosu.asc /usr/bin/gosu; \
	rm -r "$GNUPGHOME" /tmp/gosu.asc; \
	\
	chmod +x /usr/bin/gosu; \
# verify that the binary works
	gosu nobody true; \
	\
	yum -y remove wget dpkg; \
	yum clean all

# https://github.com/krallin/tini#using-tini
ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /tini.asc
RUN gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
        && gpg --verify /tini.asc \
        && chmod +x /tini

# Remove requiretty line which we need to remove so we can sudo a command in start_transmission.sh
RUN mv /etc/sudoers /etc/sudoers.bak && cat /etc/sudoers.bak | grep -v requiretty > /etc/sudoers

# Transmission tasks regardless of package vs source
RUN mkdir /var/log/transmission-daemon && \
	chown transmission:transmission /var/log/transmission-daemon && \
	mkdir /mnt/Downloads_In_Progress && mkdir /mnt/Downloads_Completed && \
	chown transmission:transmission /mnt/Downloads_In_Progress && \
	chown transmission:transmission /mnt/Downloads_Completed

WORKDIR /var/lib/transmission
# A few transmission settings are not settable on the command line so we need this
# https://blog.ipredator.se/howto/restricting-transmission-to-the-vpn-interface-on-ubuntu-linux.html
COPY settings.partial.json ./
COPY start.sh .
COPY healthcheck.py .
COPY drive.py .
RUN chown -R transmission:transmission . 

COPY change_transmission_uid_gid.sh /
# Note if change uid/gid script fails, we still continue. It just means the uid/gid
# will not necessarily match up with the host docker machine

ENTRYPOINT ["/tini", "-g", "--", "./start.sh"]
