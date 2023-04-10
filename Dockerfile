#-----------------------------------------------
# Build into an image ala:
#    docker build -t somename:latest .
#
# To run a shell to log into a container running
# this image:
#    docker run --rm -it somename:latest bash
#-----------------------------------------------

FROM debian:11-slim
MAINTAINER Vince Skahan "vinceskahan@gmail.com"

# we'll need this later for Docker logging
COPY logging.additions /tmp/logging.additions

# add a user and set $PATH to find pip3 install --user items
RUN    groupadd -r weewx                \
    && useradd -r -g weewx weewx        \
    && mkdir -p /home/weewx/.local      \
    && echo "PATH=/home/weewx/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" >> /home/weewx/.bashrc \
    && chown -R weewx:weewx /home/weewx \
    && chmod -R 755 /home/weewx

# need pip and a few odds and ends
#    cleanup of apt remnants courtesy of:
#     https://gist.github.com/marvell/7c812736565928e602c4
#
RUN apt-get update                                     \
    && apt-get install -y python3-pip sqlite3 wget vim \
    && apt-get clean autoclean                         \
    && apt-get autoremove --yes                        \
    && rm -rf /var/lib/{apt,dpkg,cache,log}            \
    && rm -rf /usr/share/doc                           \
    && rm -rf /usr/share/man                           \
    && rm -rf /usr/share/locale/[a-d]*                 \
    && rm -rf /usr/share/locale/[f-z]*                 \
    && rm -rf /usr/share/locale/e[a-m]*                \
    && rm -rf /usr/share/locale/e[o-z]* 

#--- run the rest unprvileged ---

USER weewx
ENV PATH /home/weewx/.local/bin:$PATH

# save needed drivers and extensions to a scratch dir
# for later derived images to easily install from
#
# unaltered upstream items are first here
# then forks and custom skins and extensions
RUN mkdir -p /home/weewx/adds \
    && cd /home/weewx/adds\
    && wget -nv https://github.com/captain-coredump/weatherflow-udp/archive/refs/heads/master.zip          -O weatherflow-udp.zip    \
    && wget -nv https://github.com/matthewwall/weewx-interceptor/archive/refs/heads/master.zip             -O interceptor.zip        \
    && wget -nv https://github.com/gjr80/weewx-gw1000/archive/refs/heads/master.zip                        -O ecowitt.zip            \
    && wget -nv https://github.com/poblabs/weewx-belchertown/archive/refs/heads/master.zip                 -O belchertown.zip        \
    && wget -nv https://github.com/bellrichm/WeeWX-MQTTSubscribe/archive/refs/tags/v2.2.2.zip              -O mqtt-subscribe.zip     \
    && wget -nv https://github.com/tkeffer/weewx-xaggs/archive/refs/heads/master.zip                       -O xaggs.zip              \
    && wget -nv https://github.com/vinceskahan/weewx-mqtt/archive/refs/heads/disable-by-default.zip        -O mqtt.zip               \
    && wget -nv https://github.com/vinceskahan/weewx-forecast/archive/refs/heads/master.zip                -O vds-weewx-forecast.zip \
    && wget -nv https://github.com/vinceskahan/weewx-purpleair/archive/refs/heads/master.zip               -O vds-purpleair.zip      \
    && wget -nv https://github.com/vinceskahan/vds-weewx-lastrain-extension/archive/refs/heads/master.zip  -O lastrain.zip           \
    && wget -nv https://github.com/vinceskahan/vds-weewx-local-skin/archive/refs/heads/master.zip          -O vds-local-skin.zip     \
    && wget -nv https://github.com/vinceskahan/vds-weewx-v3-mem-extension/archive/refs/heads/master.zip    -O vds-mem-extension.zip  \
    && wget -nv https://github.com/vinceskahan/vds-weewx-bootstrap-skin/archive/refs/heads/master.zip      -O vds-bootstrap-skin.zip 

# install and configure weewx
#    paho is needed for mqtt
#    create a default station then reconfigure with weectl
#       setting debug=1 can't be done via weectl
#       logging additions are needed due to no syslog in a docker image
#       and StdPrint is removed to stop LOOP from being logged

RUN    pip3 install --user paho-mqtt         \
    && pip3 install --user weewx             \
    && weectl station create --no-prompt \
    && sed -i -e s:debug\ =\ 0:debug\ =\ 1: /home/weewx/weewx-data/weewx.conf \
    && sed -i -e s:weewx.engine.StdPrint,:: /home/weewx/weewx-data/weewx.conf \
    && cat /tmp/logging.additions >> /home/weewx/weewx-data/weewx.conf

RUN  weectl station reconfigure \
--driver=weewx.drivers.simulator \
--altitude=365,foot \
--units=us \
--latitude=47.31 \
--longitude=-121.36 \
--register=y \
--station-url=http://my.test.site \
--location="(pip3 docker testing deb11) Federal Way WA USA" \
--units=us \
--html-root=/home/weewx/weewx-data/public_html 

CMD weewxd
