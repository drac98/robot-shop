#!/bin/sh
sleep 105m
echo "Dispatch memory leak"
stress-ng --vm 1 --vm-bytes 1M -t 5m
for mem in {5..345..20}; do
    stress-ng --vm 1 --vm-bytes ${mem}M -t 10m
done
stress-ng --vm 1 --vm-bytes 350M -t 5m

