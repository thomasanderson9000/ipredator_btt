FROM centos:7
MAINTAINER "Anonymous" <anon@coward>

RUN yum install -y socat sudo

# Remove requiretty line which we need to remove so we can sudo a command in start.sh
RUN mv /etc/sudoers /etc/sudoers.bak && cat /etc/sudoers.bak | grep -v requiretty > /etc/sudoers

COPY forward_port.sh /
# This listens on the host and forwards the connection to the transmission daemon
# This seems like the only way to get the port exposed once we're connected to the vpn
ENTRYPOINT ["/forward_port.sh"]
