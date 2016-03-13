FROM centos:7
MAINTAINER "Anonymous" <anon@coward>

RUN yum install -y epel-release

# Build transmission from source until we get a package
RUN yum groupinstall 'Development Tools' -y
RUN yum install libcurl-devel libevent-devel zlib-devel openssl-devel -y
ENV TM_VERSION=transmission-2.92
WORKDIR /tmp
RUN curl -O https://download.transmissionbt.com/files/$TM_VERSION.tar.xz
RUN tar xf $TM_VERSION.tar.xz
WORKDIR /tmp/$TM_VERSION
RUN ./configure && make && make install
WORKDIR /
RUN rm -rf /tmp/$TM_VERSION
RUN groupadd -r transmission
RUN useradd -r -g transmission -s /sbin/nologin transmission

# Transmission tasks regardless of package vs source
RUN mkdir /mnt/Downloads_In_Progress && mkdir /mnt/Downloads_Completed
RUN chown transmission:transmission /mnt/Downloads_In_Progress && chown transmission:transmission /mnt/Downloads_Completed
RUN mkdir -p /home/transmission/.config/transmission-daemon
# A few transmission settings are not settable on the command line so we need this
# https://blog.ipredator.se/howto/restricting-transmission-to-the-vpn-interface-on-ubuntu-linux.html
COPY settings.json /home/transmission/.config/transmission-daemon/settings.json
RUN chown -R transmission:transmission /home/transmission
RUN mkdir /var/log/transmission-daemon && chown transmission:transmission /var/log/transmission-daemon

RUN yum install -y sudo iproute
# Debugging comment out when done
RUN yum install -y links telnet


# Remove requiretty line which we need to remove so we can sudo a command in start.sh
RUN mv /etc/sudoers /etc/sudoers.bak && cat /etc/sudoers.bak | grep -v requiretty > /etc/sudoers

COPY start_transmission.sh /

#CMD tail -F nofile.log
ENTRYPOINT sudo -u transmission /start_transmission.sh
