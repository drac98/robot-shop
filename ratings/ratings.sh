#!/bin/sh

echo "Ratings high CPU usage"
stress-ng --cpu 80 --cpu-load 1 -t 5m
for load in {5..85..5}; do
    stress-ng --cpu 80 --cpu-load $load -t 5m
done
stress-ng --cpu 80 --cpu-load 90 -t 5m