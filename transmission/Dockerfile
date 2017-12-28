FROM centos:7
MAINTAINER "Anonymous" <anon@coward>

RUN yum install -y epel-release && \
		yum install -y transmission-daemon sudo iproute python-pip python-devel gcc && \
		pip install --upgrade setuptools pip && \
		pip install shifter requests netifaces psutil

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
COPY drive.py .
RUN chown -R transmission:transmission . 

COPY change_transmission_uid_gid.sh /
# Note if change uid/gid script fails, we still continue. It just means the uid/gid
# will not necessarily match up with the host docker machine
ENTRYPOINT /change_transmission_uid_gid.sh; \
           chown transmission:transmission ./.config; \
           sudo -u transmission python -u ./drive.py
