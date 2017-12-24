FROM centos:7
MAINTAINER "Anonymous" <anon@coward>

RUN yum install -y epel-release
RUN yum install -y python-pip curl
RUN pip install --upgrade setuptools
RUN pip install flexget transmissionrpc

RUN groupadd -r flexget && useradd --create-home --system -g flexget -s /sbin/nologin flexget

# Debugging comment out when done
RUN yum install -y links telnet net-tools

COPY start_flexget.sh /
COPY replace_env_vars.py /
COPY config.yml /config.yml
RUN mkdir /flexget
VOLUME /flexget
CMD /start_flexget.sh
