#---
#
# this builds a docker image of weewx set by default to simulator mode
# with debug=1 and logging set to go to stdout
#
# some of the most used drivers/extensions/skins are included
#
# drivers:
#   weatherflow-udp
#   interceptor
#
# skins:
#   Belchertown
#
# extensions:
#   MQTTSubscribe
#   mqtt - forked from upstream to disable by default
#
#
# Corequisites included:
#    py3-paho-mqtt for mqtt extension
#    rtl-sdr and rtl_433 for interceptor driver
#
#
# note this sets the timezone to America/Los_Angeles in 'two' places
# before pip3 installs anything...
#
#---

FROM alpine:3.17.0
ENV TZ=America/Los_Angeles
COPY logging.additions /tmp/logging.additions
RUN apk add tzdata python3 py3-configobj py3-pyserial py3-usb py3-pillow py3-cheetah py3-pip \
            py3-paho-mqtt rtl-sdr rtl_433 \
  && cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime \
  && pip3 install pyephem \
     && mkdir -p /tmp/weewx \
     && wget https://www.weewx.com/downloads/released_versions/weewx-4.9.1.tar.gz -O /tmp/weewx/weewx.tgz \
     && cd /tmp/weewx \
        && tar zxvf weewx.tgz \
            && cd weewx-4.9.1 \
            && python3 setup.py build \
            && python3 setup.py install --no-prompt \
        \
        && mkdir -p /home/weewx/archive /home/weewx/public_html \
        \
        && cat /tmp/logging.additions >> /home/weewx/weewx.conf \
        && sed -i -e s:My\ Little\ Town,\ Oregon:My\ Test\ Location,\USA: /home/weewx/weewx.conf \
        && sed -i -e s:debug\ =\ 0:debug\ =\ 1: /home/weewx/weewx.conf \
        && sed -i -e s:weewx.engine.StdPrint,\ :: /home/weewx/weewx.conf \
        \
        && cd /tmp/weewx \
        \
        && wget https://github.com/captain-coredump/weatherflow-udp/archive/refs/heads/master.zip -O weatherflow-udp.zip \
        && /home/weewx/bin/wee_extension --install weatherflow-udp.zip \
        \
        && wget https://github.com/matthewwall/weewx-interceptor/archive/refs/heads/master.zip -O interceptor.zip \
        && /home/weewx/bin/wee_extension --install interceptor.zip \
        \
        && wget https://github.com/poblabs/weewx-belchertown/archive/refs/heads/master.zip -O belchertown.zip \
        && /home/weewx/bin/wee_extension --install belchertown.zip  \
        \
        && wget https://github.com/bellrichm/WeeWX-MQTTSubscribe/archive/refs/tags/v2.2.2.zip -O mqtt-subscribe.zip \
        && /home/weewx/bin/wee_extension --install mqtt-subscribe.zip \
        \
        && wget https://github.com/vinceskahan/weewx-mqtt/archive/refs/heads/disable-by-default.zip -O mqtt.zip \
        && /home/weewx/bin/wee_extension --install mqtt.zip \
        \
        && cd /tmp \
        && rm -rf /tmp/weewx /tmp/logging.additions \
        \
  && apk del py3-pip
CMD /home/weewx/bin/weewxd
