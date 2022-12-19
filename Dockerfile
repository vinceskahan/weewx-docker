FROM alpine:3.17.0
COPY logging.additions /tmp/logging.additions
RUN apk add python3 py3-configobj py3-pyserial py3-usb py3-pillow py3-cheetah py3-pip \
  && pip3 install pyephem \
     && mkdir -p /tmp/weewx \
     && wget http://www.weewx.com/downloads/weewx-4.9.1.tar.gz -O /tmp/weewx/weewx.tgz \
     && cd /tmp/weewx \
        && tar zxvf weewx.tgz \
            && cd weewx-4.9.1 \
            && python3 setup.py build \
            && python3 setup.py install --no-prompt \
        \
        && mkdir -p /home/weewx /home/weewx/archive /home/weewx/public_html \
        && cat /tmp/logging.additions >> /home/weewx/weewx.conf \
        && sed -i -e s:My\ Little\ Town,\ Oregon:My\ Test\ Location,\USA: /home/weewx/weewx.conf \
        && sed -i -e s:debug\ =\ 0:debug\ =\ 1: /home/weewx/weewx.conf \
        && sed -i -e s:weewx.engine.StdPrint,\ :: /home/weewx/weewx.conf \
        \
        && wget https://github.com/poblabs/weewx-belchertown/archive/refs/heads/master.zip -O /tmp/weewx/belchertown.zip \
        && /home/weewx/bin/wee_extension --install /tmp/weewx/belchertown.zip  \
        \
        && rm -rf /tmp/weewx /tmp/logging.additions \
  && apk del py3-pip
CMD /home/weewx/bin/weewxd
