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

# wait for deluge to start if needed
echo "logging in and getting the cookie"
COOKIE=$(wget --quiet --output-document - --tries ${MAX_TRIES:-0} --waitretry ${MAX_DELAY:-10} --retry-connrefused --save-headers --header "Content-Type: application/json" --post-data '{"method": "auth.login", "params": ["'$DELUGE_PASSWORD'"], "id": '$RANDOM'}' http://localhost:8112/json | grep Cookie)
if [[ -z "$COOKIE" ]]; then
  echo "login failed"
  exit 1
fi

# set the incoming port
HOST_ID=$(wget --quiet --output-document - --header "${COOKIE#Set-}" --header "Content-Type: application/json" --post-data '{"method": "web.get_hosts", "params": [], "id": '$RANDOM'}' http://localhost:8112/json | cut -d'"' -f4)
echo -e "connecting the web client to the daemon using host id: $HOST_ID"
wget --quiet --output-document - --header "${COOKIE#Set-}" --header "Content-Type: application/json" --post-data '{"method": "web.connect", "params": ["'$HOST_ID'"], "id": '$RANDOM'}' http://localhost:8112/json
echo -e "\nsetting random port option to false"
wget --quiet --output-document - --header "${COOKIE#Set-}" --header "Content-Type: application/json" --post-data '{"method": "core.set_config", "params": [{"random_port": false}], "id": '$RANDOM'}' http://localhost:8112/json
echo -e "\nsetting the port to $PORT"
wget --quiet --output-document - --header "${COOKIE#Set-}" --header "Content-Type: application/json" --post-data '{"method": "core.set_config", "params": [{"listen_ports": ['$PORT','$PORT']}], "id": '$RANDOM'}' http://localhost:8112/json
