
## Run weewx under Docker

This branch does v5 via pip over a debian 11 slim starting point, and spins up an accompanying nginx server.

### To build
docker build -t test:latest

### To run
docker-compose up -d

### For logs
docker-compose logs [-f]
