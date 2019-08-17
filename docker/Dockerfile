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
    libcrypt-ssleay-perl\
    wget \
    make \
    rrdtool \
    librrds-perl \    
    g++ \
    php-cli \
    php-gd \
    php-xml \
    libapache2-mod-php

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



    # download and install pnp4nagios
RUN wget -O pnp4nagios.zip https://github.com/lingej/pnp4nagios/archive/master.zip && \
  unzip pnp4nagios.zip && \
  cd pnp4nagios-master && \
  ./configure --with-nagios-user=naemon --with-nagios-group=naemon && \
  make all && \
  make install && \
  make install-webconf && \
  make install-config && \
  make install-init && \
  cd ../ && \
  rm -rf pnp4nagios.zip pnp4nagios-master

#
# # Install the check_wp_update plugin
# #

ADD plugins/check_hackedfiles /usr/lib/naemon/plugins/check_hackedfiles
RUN sync && chmod 755 /usr/lib/naemon/plugins/check_hackedfiles



 RUN rm -rf /etc/naemon/conf.d/localhost.cfg
 ADD definition/wordpresshosts.cfg /etc/naemon/conf.d/wordpresshosts.cfg 

 ADD definition/wordpressservices.cfg /etc/naemon/conf.d/wordpressservices.cfg 
COPY thruk_root_redirect.conf /etc/apache2/conf-enabled/


# configure pnp4nagios and thruk
RUN mv /etc/httpd/conf.d/pnp4nagios.conf /etc/apache2/conf-available && \
  ln -sf /etc/apache2/conf-available/pnp4nagios.conf /etc/apache2/conf-enabled/pnp4nagios.conf && \
  sed -i "s|\$conf\['nagios_base'\].*=.*\".*\";|\$conf['nagios_base'] = \"/thruk/cgi-bin\";|" /usr/local/pnp4nagios/etc/config_local.php && \
  sed -i 's;RewriteCond\s\+%{REQUEST_URI}\s\+\^/thruk$;RewriteCond %{REQUEST_URI}           ^/(thruk|pnp4nagios);g' /usr/share/thruk/thruk_cookie_auth.include && \
  rm -f /usr/local/pnp4nagios/share/install.php



  # set time zone
ARG TIME_ZONE=Etc/UTC
RUN ln -sf "/usr/share/zoneinfo/$TIME_ZONE" /etc/localtime && echo "$TIME_ZONE" > /etc/timezone
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




# All data is stored on the root data volme
#
VOLUME ["/data"]

# Expose ports for sharing
EXPOSE 3


EXPOSE 80/tcp

ENTRYPOINT /run.bash 
#${NAEMON_HOST}