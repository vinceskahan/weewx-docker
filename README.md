
## Run weewx under Docker

This repo provides a Dockerfile for building weewx in simulator mode plus the Belchertown skin.

The docker-compose.yml file will bring up a matching nginx container and listen on the normal web port 80.

### To build

docker build -t weewx/sim:4.9.1 .

### To run

docker-compose up -d

### To open a shell into the weewx container

docker run --rm -it weewx/sim:4.9.1 bash

### To view logs

docker-compose logs -f weewx

### To view the web

open http://hostname/weewx/ for the default skin

open http://hostname/weewx/belchertown/ for Belchertown


