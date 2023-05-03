#!/bin/bash
sleep 1095m
#0-100m packetloss
tc qdisc add dev eth0 root netem loss 1%
sleep 5m
tc qdisc del dev eth0 root
for rate in {5..90..5}; do
    tc qdisc add dev eth0 root netem loss ${rate}%
    sleep 5m
    tc qdisc del dev eth0 root

done

#95-185m low bandwidth
sleep m
for rate in 256 128 64 32 16 8 4 2 1; do
    tc qdisc add dev eth0 root tbf rate ${rate}kbps burst 256 latency 50ms
    sleep 5m
    tc qdisc del dev eth0 root

    tc qdisc add dev eth0 root tbf rate ${rate}kbps burst 64 latency 50ms
    sleep 5m
    tc qdisc del dev eth0 root

done
sleep 5m 


#180-265m high latency
tc qdisc add dev eth0 root netem delay 20ms
sleep 5m
tc qdisc del dev eth0 root
for rate in {100..1500..100}; do
    tc qdisc add dev eth0 root netem delay {$rate}ms
    sleep 5m
    tc qdisc del dev eth0 root

done
sleep 5m 

#260-360m out-of-order packets
tc qdisc add dev eth0 root netem delay 50ms reorder 60% 60%
sleep 5m
tc qdisc del dev eth0 root
for rate in {5..90..5}; do
    tc qdisc add dev eth0 root netem delay 50ms reorder {$rate}% {$rate}%
    sleep 5m
    tc qdisc del dev eth0 root

done
