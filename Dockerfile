FROM alpine:3.17.0
COPY logging.additions /tmp/logging.additions
RUN apk add python3 py3-configobj py3-pyserial py3-usb py3-pillow py3-cheetah py3-pip \
  && pip3 install pyephem \
     && wget http://www.weewx.com/downloads/weewx-4.9.1.tar.gz -O /tmp/weewx.tgz \
     && cd /tmp && tar zxvf weewx.tgz && cd weewx-4.9.1 && python3 setup.py build && python3 setup.py install --no-prompt \
     && cat /tmp/logging.additions >> /home/weewx/weewx.conf \
     && rm -rf /tmp/weewx* /tmp/logging.additions \
  && apk del py3-pip
CMD /home/weewx/bin/weewxd
