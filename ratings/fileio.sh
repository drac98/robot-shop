#!/bin/sh

echo "cart high file-io"
stress-ng --io 1 --hdd-bytes 1M --timeout 5m
for mem in {5..260..15}; do
    stress-ng --io 1 --hdd-bytes {$mem}M --timeout 5m
done
stress-ng --io 1 --hdd-bytes 265M --timeout 5m