FROM centos:7
MAINTAINER "Anonymous" <anon@coward>

RUN yum install -y epel-release
RUN yum install transmission-daemon -y

RUN yum install -y sudo iproute

# Remove requiretty line which we need to remove so we can sudo a command in start_transmission.sh
RUN mv /etc/sudoers /etc/sudoers.bak && cat /etc/sudoers.bak | grep -v requiretty > /etc/sudoers

# Transmission tasks regardless of package vs source
RUN mkdir /var/log/transmission-daemon && chown transmission:transmission /var/log/transmission-daemon
RUN mkdir /mnt/Downloads_In_Progress && mkdir /mnt/Downloads_Completed
RUN chown transmission:transmission /mnt/Downloads_In_Progress && chown transmission:transmission /mnt/Downloads_Completed
WORKDIR /var/lib/transmission
# A few transmission settings are not settable on the command line so we need this
# https://blog.ipredator.se/howto/restricting-transmission-to-the-vpn-interface-on-ubuntu-linux.html
COPY settings.partial.json ./
# This will be read in by start_transmission.sh. Doing this to make it easy to restart if needed.
RUN touch ./transmission-daemon-extra-args
COPY start_transmission.sh . 
RUN chown -R transmission:transmission . 

COPY change_transmission_uid_gid.sh /
RUN echo "${TRANSMISSION_DAEMON_ARGS}" > ./transmission-daemon-extra-args
# Note if change uid/gid script fails, we still continue. It just means the uid/gid
# will not necessarily match up with the host docker machine
ENTRYPOINT echo -n "${TRANSMISSION_DAEMON_ARGS}" > ./transmission-daemon-extra-args; \
           /change_transmission_uid_gid.sh; \
           chown transmission:transmission ./.config; \
           sudo -u transmission ./start_transmission.sh
