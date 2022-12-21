
## Run weewx under Docker

This repo provides a Dockerfile for building weewx in simulator mode plus the Belchertown skin with some other items installed in some cases. See the Dockerfile on the appropriate branch for details.

The docker-compose.yml file will bring up a matching nginx container and listen on a port mapped to the Docker host.  See the docker-compose.yml file for details.

### Why is this branch empty

I've refactored to put os-specific implementations on their own branch.  Set yourself to the appropriate branch to poke around a bit.

