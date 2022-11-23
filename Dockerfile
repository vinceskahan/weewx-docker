#-----------------------------------------------
# install weewx in simulator mode, plus some typical extensions and skins
# note: StdPrint is removed to quiet down LOOP messages for Docker installations
# in this example the Belchertown skin is installed and enabled in its default configuration
#
# To build
#    docker build -t weewx/sim:4.9.1 .
#
# To run a shell to log into a container running
# this image:
#    docker run --rm -it weewx/sim:4.9.1 bash
#
# on a pi4 this image is about 205 MB when done
#
# cleanup of apt remnants courtesy of:
#  https://gist.github.com/marvell/7c812736565928e602c4
#-----------------------------------------------

FROM debian:11-slim
MAINTAINER Vince Skahan "vinceskahan@gmail.com"

# we append this to weewx.conf below after installing weewx
# use custom logging rules so Docker does not require a syslogd
COPY logging.additions /tmp/logging.additions

# re: apt-get installed packages:
#    python3-paho-mqtt is needed for MQTT extension
#    rsync is needed for the uploader
#    ssh might be not needed (untested)

#--- do it all in one RUN command to minimize Docker layers
# set the timezone
# install weewx prerequisites
# clean up apt remnants
# install and minimally configure weewx
# install the Belchertown skin in its default configuration

RUN TIMEZONE="US/Pacific" \
    && rm /etc/timezone \
    && rm /etc/localtime \
    && echo $TIMEZONE > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    \
    && apt-get update \
    && apt-get install -y \
            python3-configobj \
            python3-cheetah \
            python3-pil \
            python3-serial \
            python3-usb \
            python3-ephem \
            sqlite3 unzip python3-distutils wget rsync ssh \
            python3-paho-mqtt \
    \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log} \
    && rm -rf /usr/share/doc \
    && rm -rf /usr/share/man \
    && rm -rf /usr/share/locale/[a-d]* \
    && rm -rf /usr/share/locale/[f-z]* \
    && rm -rf /usr/share/locale/e[a-m]* \
    && rm -rf /usr/share/locale/e[o-z]*  \
    \
    && wget http://www.weewx.com/downloads/released_versions/weewx-4.9.1.tar.gz -O /tmp/weewx.tgz \
      && cd /tmp && tar zxvf /tmp/weewx*.tgz \
      && cd weewx-* && python3 ./setup.py build && python3 ./setup.py install --no-prompt \
      \
      && cat /tmp/logging.additions >> /home/weewx/weewx.conf \
      \
      && mkdir -p /home/weewx/archive /home/weewx/public_html \
      \
      && sed -i -e s:My\ Little\ Town,\ Oregon:My\ Test\ Location,\USA: /home/weewx/weewx.conf \
      && sed -i -e s:debug\ =\ 0:debug\ =\ 1: /home/weewx/weewx.conf \
      && sed -i -e s:weewx.engine.StdPrint,\ :: /home/weewx/weewx.conf \
      \
      && wget https://github.com/poblabs/weewx-belchertown/archive/refs/heads/master.zip -O /tmp/belchertown.zip \
      && /home/weewx/bin/wee_extension --install /tmp/belchertown.zip 

#
# unforunately these throw errors if installed but not configured
# so they are commented out here at this time
#
# weewx using configobj makes it non-trivial to insert a 'enable=false' line into the right place
# in weewx.conf, as well as simply trying to disable an unconfigured skin.  Ugh.
#
#      && wget https://github.com/matthewwall/weewx-mqtt/archive/master.zip -O /tmp/weewx-mqtt.zip \
#         && /home/weewx/bin/wee_extension --install /tmp/weewx-mqtt.zip \
#      \
#      && wget https://github.com/bellrichm/WeeWX-MQTTSubscribe/archive/refs/heads/master.zip -O /tmp/bellrichm_MQTTSubscribe.zip \
#      && /home/weewx/bin/wee_extension --install /tmp/bellrichm_MQTTSubscribe.zip
#

#-- fire it up --
CMD ["/home/weewx/bin/weewxd"]

