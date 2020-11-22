#!/bin/bash

# This script will create/delete:
#   - 3 network namespaces
#   - 3 ovs ports
#   - 1 ovs bridge
#

set -e

function log {
    echo "$(date) | INFO | $1"
}

IP_PREFIX="10.200.200"
IP_CIDR="24"

function create {
    log "create bridge with name switch1"
    ovs-vsctl add-br switch1

    log "fire up switch1"
    ip link set dev switch1 up

    for i in 1 2 3; do
        log "create netns host$i"
        ip netns add host$i

        log "create ovs ports (h$i-eth0 and its ovs internal peer) for netns host$i"
        ovs-vsctl add-port switch1 h$i-eth0 -- set Interface h$i-eth0 type=internal

        log "move h$i-eth0 to host$i"
        ip link set h$i-eth0 netns host$i

        log "add $IP_PREFIX.$i/$IP_CIDR ip address to h$i-eth0"
        ip netns exec host$i ip addr add "$IP_PREFIX.$i/$IP_CIDR" dev h$i-eth0

        log "bring up h$i-eth0"
        ip netns exec host$i ip link set dev h$i-eth0 up
    done

    log "done"
}

function delete {
    for i in 1 2 3; do
        log "delete host$i"
        ip netns del host$i
    done

    log "delete switch1"
    ovs-vsctl del-br switch1

    log "done"
}

if [ "$1" = "create" ]; then
  create
elif [ "$1" = "delete" ]; then
  delete
else
  echo "This creates/deletes 3 netns, 3 ovs ports and 1 ovs bridge"
  echo ""
  echo "  Usage: $0 <create|delete>"
  echo ""
fi