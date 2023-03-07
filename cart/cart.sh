#!/bin/sh

echo "CARTTTTTTTTTTTTTTTTTTTTTTTTT"
stress-ng --vm 1 --vm-bytes 25M -t 10m
stress-ng --vm 1 --vm-bytes 50M -t 20m
stress-ng --vm 1 --vm-bytes 100M -t 20m
stress-ng --vm 1 --vm-bytes 150M -t 30m
stress-ng --vm 1 --vm-bytes 200M -t 30m
stress-ng --vm 1 --vm-bytes 250M -t 30m
stress-ng --vm 1 --vm-bytes 300M -t 30m

