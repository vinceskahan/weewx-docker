# Docker implementation of weewx in simulator mode

This small set of files lets you spin up a working Docker instance of weewx on top of minimal ubuntu within just a minute or two, depending on your bandwidth.

Yes, I called the resulting image 'weebuntu' :-)

## how to build and use

* strongly suggest just using docker-compose to build and start it
* the yaml file above here:
    * starts this container
    * exposes its public_html and archive directories to directories on the host
    * starts a vanilla nginx container that uses this public_html directory as its docroot

