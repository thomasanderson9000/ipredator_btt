FROM centos:7
MAINTAINER "Anonymous" <anon@coward>

RUN yum install -y dnsmasq 

WORKDIR /root

COPY start_dns.sh .

ENTRYPOINT ["./start_dns.sh"]
 
