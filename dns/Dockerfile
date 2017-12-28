FROM centos:7
MAINTAINER "Anonymous" <anon@coward>

RUN yum install -y epel-release
RUN yum install -y dnsmasq python-pip 
RUN pip install --upgrade setuptools pip
RUN pip install flask

WORKDIR /root

COPY set_dns.py .
COPY start_dns.sh .

ENTRYPOINT ["./start_dns.sh"]
 
