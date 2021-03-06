FROM centos:7
MAINTAINER "Anonymous" <anon@coward>

ENV GOSU_VERSION 1.10
RUN set -ex; \
	\
	yum -y install epel-release; \
    yum install -y openvpn sudo bind-utils wget dpkg; \
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

RUN yum install -y python2-pip python-devel gcc && pip install --upgrade setuptools pip && \
        pip install psutil

COPY sysctl.conf /etc
COPY ./etc_openvpn/ /etc/openvpn/
# start_vpn.sh will populate this file from environment variables
ENV VPN_AUTH_FILE /etc/openvpn/vpn.auth
RUN touch $VPN_AUTH_FILE && chown -R root:openvpn /etc/openvpn/* && chmod -R ug+rX /etc/openvpn/* && chmod o-rwx /etc/openvpn/*

# Allow us to run openvpn as openvpn user
RUN echo "openvpn ALL=(ALL) NOPASSWD: /sbin/ip" >> /etc/sudoers
# /etc/resolv.conf gets root perms even after I reset them
# this will fix that
RUN echo "openvpn ALL=(ALL) NOPASSWD:SETENV: /etc/openvpn/update-resolv-conf.py" >> /etc/sudoers
COPY unpriv-ip /usr/local/sbin/
# Remove requiretty line which we need to remove so we can sudo a command in start_vpn.sh
RUN mv /etc/sudoers /etc/sudoers.bak && cat /etc/sudoers.bak | grep -v requiretty > /etc/sudoers

WORKDIR /etc/openvpn
COPY start_vpn.py /

# python -u for unbuffered output
ENTRYPOINT ["/tini", "-g", "--", "python", "-u", "/start_vpn.py"]
