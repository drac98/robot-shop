#!/bin/sh

echo "Ratings memory leak"
stress-ng --vm 1 --vm-bytes 1M -t 10m
stress-ng --vm 1 --vm-bytes 25M -t 5m
stress-ng --vm 1 --vm-bytes 50M -t 10m
stress-ng --vm 1 --vm-bytes 75M -t 10m
stress-ng --vm 1 --vm-bytes 125M -t 15m
stress-ng --vm 1 --vm-bytes 250M -t 15m
stress-ng --vm 1 --vm-bytes 300M -t 20m
stress-ng --vm 1 --vm-bytes 350M -t 20m

