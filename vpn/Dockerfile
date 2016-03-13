FROM centos:7
MAINTAINER "Anonymous" <anon@coward>

RUN yum install -y epel-release
RUN yum install -y openvpn sudo 

COPY sysctl.conf /etc
COPY IPredator-CLI-Password.conf /etc/openvpn/
# start_vpn.sh will populate this file from environment variables
ENV IPRED_AUTH_FILE /etc/openvpn/IPredator.auth
RUN touch $IPRED_AUTH_FILE && chown -R root:openvpn /etc/openvpn && chmod -R 0640 /etc/openvpn/*

# Allow us to run openvpn as openvpn user
RUN echo "openvpn ALL=(ALL) NOPASSWD: /sbin/ip" >> /etc/sudoers
COPY unpriv-ip /usr/local/sbin/
# Remove requiretty line which we need to remove so we can sudo a command in start_vpn.sh
RUN mv /etc/sudoers /etc/sudoers.bak && cat /etc/sudoers.bak | grep -v requiretty > /etc/sudoers

COPY start_vpn.sh /

ENTRYPOINT ["/start_vpn.sh"]
