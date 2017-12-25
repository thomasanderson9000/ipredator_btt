FROM centos:7
# This image will enable/disable dht and pex depending on active torrents
MAINTAINER "Anonymous" <anon@coward>

RUN yum install -y epel-release
RUN yum install -y python-pip
RUN pip install --upgrade setuptools
RUN pip install shifter

COPY control_transmission.py / 
ENTRYPOINT ["python", "/control_transmission.py"]
