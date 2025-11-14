# gluetun-port-forwarding-deluge
Set up gluetun native port forwarding to configure deluge automatically.

Gluetun must support native port forwarding integration with your VPN provider. See the [gluetun wiki](https://github.com/qdm12/gluetun-wiki/blob/main/setup/advanced/vpn-port-forwarding.md) for an up-to-date list of supported providers.

## Setup
1. Download `compose.yaml` or copy the contents into your compose editor
2. Edit the compose file for your environment
    * Configure gluetun for your provider
    * Configure the script with your deluge password
    * Bind mount a directory to give gluetun access to the script
    * Configure deluge for your environment
3. Download `update-port.sh` to the bind mounted directory

## Run
Bring the stack up, such as with `docker compose up -d`
