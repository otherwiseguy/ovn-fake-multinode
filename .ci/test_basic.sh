#!/bin/bash -xe

PODMAN_BIN=${1:-podman}

# Simple configuration sanity checks
$PODMAN_BIN exec -it ovn-central ovn-nbctl show > nb_show
$PODMAN_BIN exec -it ovn-central ovn-sbctl show > sb_show

grep "(public)" nb_show
grep "(sw0)" nb_show
grep "(sw1)" nb_show
grep "(lr0)" nb_show


grep "Chassis ovn-gw-1" sb_show
grep "Chassis ovn-chassis-1" sb_show
grep "Chassis ovn-chassis-2" sb_show


# Some pings between the containers
$PODMAN_BIN exec -it ovn-chassis-1 ping -c 1 -w 1 170.168.0.2
$PODMAN_BIN exec -it ovn-chassis-1 ping -c 1 -w 1 170.168.0.3
$PODMAN_BIN exec -it ovn-chassis-1 ping -c 1 -w 1 170.168.0.5

$PODMAN_BIN exec -it ovn-chassis-2 ping -c 1 -w 1 170.168.0.2
$PODMAN_BIN exec -it ovn-chassis-2 ping -c 1 -w 1 170.168.0.3
$PODMAN_BIN exec -it ovn-chassis-2 ping -c 1 -w 1 170.168.0.4

$PODMAN_BIN exec -it ovn-gw-1 ping -c 1 -w 1 170.168.0.2
$PODMAN_BIN exec -it ovn-gw-1 ping -c 1 -w 1 170.168.0.4
$PODMAN_BIN exec -it ovn-gw-1 ping -c 1 -w 1 170.168.0.5


# Check expected routes from nested namespaces

$PODMAN_BIN exec -it ovn-chassis-1 ip netns

# sw0p1 : dual stack
$PODMAN_BIN exec -it ovn-chassis-1 ip netns exec sw0p1 ip -4 route > sw0p1_route
$PODMAN_BIN exec -it ovn-chassis-1 ip netns exec sw0p1 ip -6 route >> sw0p1_route
cat sw0p1_route
grep "10.0.0.0/24 dev sw0p1" sw0p1_route
grep "default via 10.0.0.1 dev sw0p1" sw0p1_route
grep "1000::/64 dev sw0p1" sw0p1_route
grep "default via 1000::a dev sw0p1" sw0p1_route

echo 'happy happy, joy joy'
