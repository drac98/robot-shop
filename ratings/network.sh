#!/bin/bash
sleep 300m
tc qdisc add dev eth0 root netem loss 1%
sleep 5m
tc qdisc del dev eth0 root
for rate in {5..90..5}; do
    tc qdisc add dev eth0 root netem loss ${rate}%
    sleep 5m
    tc qdisc del dev eth0 root

done