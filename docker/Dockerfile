FROM phusion/baseimage:0.11
MAINTAINER Sofia <chui274@gmail.com>

#
# Install the baseline packages for this image. Note, these 
# packages are not version controlled and may change between
# builds.
#
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install -y \
    apache2\
    apache2-utils\
    libapache2-mod-fcgid\
    libfontconfig1\
    libjpeg62\
    libgd3\
    libxpm4\
    xvfb\
    ssmtp\
    ruby\
    python2.7\
    python-boto\
    perl\
    libwww-perl\
    libcrypt-ssleay-perl

#
# Instal the GPG key for the labs.consol.de repository and install 
# the repository
#
RUN   curl -s "https://labs.consol.de/repo/stable/RPM-GPG-KEY" | apt-key add -
RUN   gpg --keyserver keys.gnupg.net --recv-keys F8C1CA08A57B9ED7
RUN	  gpg --armor --export F8C1CA08A57B9ED7 | apt-key add - && \
	  echo "deb http://labs.consol.de/repo/stable/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/labs-consol-stable.list

RUN apt-get update &&\
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    nagios-nrpe-plugin\
    naemon=1.0.10

RUN rm -rf /etc/naemon/conf.d/templates
RUN rm -rf /etc/naemon/conf.d/windows.cfg
RUN rm -rf /etc/naemon/conf.d/switch.cfg
RUN rm -rf /etc/naemon/conf.d/printer.cfg
RUN rm -rf /etc/naemon/conf.d/contacts.cfg
ADD hosts.cfg /etc/naemon/conf.d/hosts.cfg 
ADD services.cfg /etc/naemon/conf.d/services.cfg 
COPY thruk_root_redirect.conf /etc/apache2/conf-enabled/

#
# Perform the data directory initialization
#
COPY data_dirs.env /data_dirs.env
ADD init.bash /init.bash

RUN chmod 755 /init.bash &&\
    sync &&  /init.bash &&\
    sync && rm /init.bash

#
# Add the bootstrap script
#
COPY run.bash /run.bash
RUN chmod 755 /run.bash

#Add file host.cfg with the configuration of the new host in the directory /etc/naemon/
#ADD hosts.cfg /etc/naemon/conf.d/hosts.cfg

#Add file services.cfg with the configuration of the new service in the directory /etc/naemon/
#ADD services.cfg /etc/naemon/conf.d/services.cfg

#Remove directoy template from /etc/naemon/conf.d/template

#RUN rm /etc/naemon/conf.d/templates
# All data is stored on the root data volme
#
VOLUME ["/data"]

# Expose ports for sharing
EXPOSE 3

EXPOSE 80/tcp

ENTRYPOINT /run.bash 
#${NAEMON_HOST}