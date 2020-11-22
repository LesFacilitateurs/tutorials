#!/bin/bash

# This script will create/delete:
#   - 3 network namespaces
#   - 3 veth pairs
#   - 1 linux bridge
#

set -e

function log {
    echo "$(date) | INFO | $1"
}

IP_PREFIX="10.200.200"
IP_CIDR="24"

function create {
    log "create bridge with name br0"
    ip link add br0 type bridge

    log "fire up br0"
    ip link set dev br0 up

    for i in 1 2 3; do
        log "create netns netns-$i"
        ip netns add netns-$i

        log "create veth pair (tap-ns-$i, tap-br-$i) for netns netns-$i"
        ip link add tap-ns-$i type veth peer name tap-br-$i

        log "move tap-ns-$i to netns-$i"
        ip link set tap-ns-$i netns netns-$i

        log "attach tap-br-$i to br0"
        ip link set tap-br-$i master br0

        log "add $IP_PREFIX.$i/$IP_CIDR ip address to tap-ns-$i"
        ip netns exec netns-$i ip addr add "$IP_PREFIX.$i/$IP_CIDR" dev tap-ns-$i

        log "bring up tap-br-$i"
        ip link set dev tap-br-$i up

        log "bring up tap-ns-$i"
        ip netns exec netns-$i ip link set dev tap-ns-$i up
    done

    log "done"
}

function delete {
    for i in 1 2 3; do
        log "delete netns-$i"
        ip netns del netns-$i
    done

    log "delete br0"
    ip link del br0

    log "done"
}

if [ "$1" = "create" ]; then
  create
elif [ "$1" = "delete" ]; then
  delete
else
  echo "This creates/deletes 3 netns, 3 veths and 1 linux bridge"
  echo ""
  echo "  Usage: $0 <create|delete>"
  echo ""
fi