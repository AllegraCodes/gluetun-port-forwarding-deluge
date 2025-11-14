#!/bin/sh

# maybe one day the deluge api will be documented
# until then, we have mhertz, deluge forum moderator, to thank for this script
# https://forum.deluge-torrent.org/viewtopic.php?p=234832

# use the first port if there are multiple
PORT=${1%%,*}
if [[ ! $PORT =~ "^[0-9]*$" ]]; then
  echo "expected argument to be a comma separated list of numbers, but was: $1"
  exit 1
fi

# install curl if needed
if [[ ! -f /usr/bin/curl ]]; then
  echo "installing curl"
  apk add --no-cache curl
fi

# give deluge a minute to start if needed
echo "logging in and getting the cookie"
COOKIE=$(curl --retry 30 --retry-delay 2 --retry-all-errors --silent --show-error --show-headers -H "Content-Type: application/json" -d '{"method": "auth.login", "params": ["'$DELUGE_PASSWORD'"], "id": '$RANDOM'}' http://localhost:8112/json | grep Cookie | cut -d':' -f2)
if [[ -z "$COOKIE" ]]; then
  echo "login failed"
  exit 1
fi

# set the incoming port
HOST_ID=$(curl --silent --show-error -H "cookie: $COOKIE" -H "Content-Type: application/json" -d '{"method": "web.get_hosts", "params": [], "id": '$RANDOM'}' http://localhost:8112/json | cut -d'"' -f4)
echo -e "connecting to the host with id: $HOST_ID"
curl --silent --show-error -H "cookie: $COOKIE" -H "Content-Type: application/json" -d '{"method": "web.connect", "params": ["'$HOST_ID'"], "id": '$RANDOM'}' http://localhost:8112/json
echo -e "\nsetting random port option to false"
curl --silent --show-error -H "cookie: $COOKIE" -H "Content-Type: application/json" -d '{"method": "core.set_config", "params": [{"random_port": false}], "id": '$RANDOM'}' http://localhost:8112/json
echo -e "\nsetting the port to $PORT"
curl --silent --show-error -H "cookie: $COOKIE" -H "Content-Type: application/json" -d '{"method": "core.set_config", "params": [{"listen_ports": ['$PORT','$PORT']}], "id": '$RANDOM'}' http://localhost:8112/json
