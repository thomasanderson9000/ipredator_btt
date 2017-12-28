FROM centos:7
MAINTAINER "Anonymous" <anon@coward>

RUN yum install -y epel-release && \
    yum install -y openvpn sudo bind-utils

COPY sysctl.conf /etc
COPY ./etc_openvpn/ /etc/openvpn/
# start_vpn.sh will populate this file from environment variables
ENV VPN_AUTH_FILE /etc/openvpn/vpn.auth
RUN touch $VPN_AUTH_FILE && chown -R root:openvpn /etc/openvpn/* && chmod -R ug+rX /etc/openvpn/* && chmod o-rwx /etc/openvpn/*

# Allow us to run openvpn as openvpn user
RUN echo "openvpn ALL=(ALL) NOPASSWD: /sbin/ip" >> /etc/sudoers
COPY unpriv-ip /usr/local/sbin/
# Remove requiretty line which we need to remove so we can sudo a command in start_vpn.sh
RUN mv /etc/sudoers /etc/sudoers.bak && cat /etc/sudoers.bak | grep -v requiretty > /etc/sudoers

WORKDIR /etc/openvpn
COPY start_vpn.py /

# python -u for unbuffered output
ENTRYPOINT ["python", "-u", "/start_vpn.py"]
