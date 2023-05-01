#!/bin/sh

# set -x

if [ -z "$HOST" ]
then
    echo "HOST env not set"
    exit 1
fi

if echo "$NUM_CLIENTS" | egrep -q '^[0-9]+$'
then
    if [ $NUM_CLIENTS -eq 0 ]
    then
        NUM_CLIENTS=1
    fi
    echo "Starting load with $NUM_CLIENTS clients"
else
    echo "NUM_CLIENTS $NUM_CLIENTS is not a number"
    exit 1
fi


if [ "$RUN_TIME" != "0" ]
then
    if echo "$RUN_TIME" | egrep -q '^([0-9]+h)?([0-9]+m)?$'
    then
        TIME="-t $RUN_TIME"
    else
        echo "Wrong time format, use 2h42m"
        exit 1
    fi
else
    unset RUN_TIME
    unset TIME
fi

echo "Starting $CLIENTS clients for ${RUN_TIME:-ever}"
# if [ "$SILENT" -eq 1 ]
# then
#     locust -f robot-shop.py --host "$HOST" --headless -r 1 -u $NUM_CLIENTS $TIME > /dev/null 2>&1
# else
#     locust -f robot-shop.py --host "$HOST" --headless -r 1 -u $NUM_CLIENTS $TIME
# fi

# period min-max users
# 0-2     3-10
# 2-6     5-20
# 6-12    15-30
# 12-17   25-50
# 17-22   40-70
# 22-0    10-20

while true; do
  current_hour=$(date +%H)

  if [ "$current_hour" -lt 2 ]
  then
    NUM_CLIENTS1=$(echo $(( $(openssl rand -hex 1 | awk '{ printf("%d\n",$0) }') % 2 + 1 )))
    NUM_CLIENTS2=$(echo $(( $(openssl rand -hex 1 | awk '{ printf("%d\n",$0) }') % 3 + 1 )))
    NUM_CLIENTS3=$(echo $(( $(openssl rand -hex 1 | awk '{ printf("%d\n",$0) }') % 5 + 1 )))
  elif [ "$current_hour" -lt 6 ]
  then
    NUM_CLIENTS1=$(echo $(( $(openssl rand -hex 1 | awk '{ printf("%d\n",$0) }') % 5 + 2 )))
    NUM_CLIENTS2=$(echo $(( $(openssl rand -hex 1 | awk '{ printf("%d\n",$0) }') % 5 + 2 )))
    NUM_CLIENTS3=$(echo $(( $(openssl rand -hex 1 | awk '{ printf("%d\n",$0) }') % 5 + 1 )))
  elif [ "$current_hour" -lt 12 ]
  then
    NUM_CLIENTS1=$(echo $(( $(openssl rand -hex 1 | awk '{ printf("%d\n",$0) }') % 4 + 3 )))
    NUM_CLIENTS2=$(echo $(( $(openssl rand -hex 1 | awk '{ printf("%d\n",$0) }') % 6 + 2 )))
    NUM_CLIENTS3=$(echo $(( $(openssl rand -hex 1 | awk '{ printf("%d\n",$0) }') % 5 + 10 )))
  elif [ "$current_hour" -lt 17 ]
  then
    NUM_CLIENTS1=$(echo $(( $(openssl rand -hex 1 | awk '{ printf("%d\n",$0) }') % 10 + 7 )))
    NUM_CLIENTS2=$(echo $(( $(openssl rand -hex 1 | awk '{ printf("%d\n",$0) }') % 8 + 8 )))
    NUM_CLIENTS3=$(echo $(( $(openssl rand -hex 1 | awk '{ printf("%d\n",$0) }') % 7 + 10 )))
  elif [ "$current_hour" -lt 22 ]
  then
    NUM_CLIENTS1=$(echo $(( $(openssl rand -hex 1 | awk '{ printf("%d\n",$0) }') % 12 + 10 )))
    NUM_CLIENTS2=$(echo $(( $(openssl rand -hex 1 | awk '{ printf("%d\n",$0) }') % 8 + 15 )))
    NUM_CLIENTS3=$(echo $(( $(openssl rand -hex 1 | awk '{ printf("%d\n",$0) }') % 10 + 15 )))
  else
    NUM_CLIENTS1=$(echo $(( $(openssl rand -hex 1 | awk '{ printf("%d\n",$0) }') % 2 + 5 )))
    NUM_CLIENTS2=$(echo $(( $(openssl rand -hex 1 | awk '{ printf("%d\n",$0) }') % 4 + 2 )))
    NUM_CLIENTS3=$(echo $(( $(openssl rand -hex 1 | awk '{ printf("%d\n",$0) }') % 4 + 3 )))
  fi
  echo "Start $NUM_CLIENTS at $current_hour"
  locust -f robot-shop.py --host "$HOST" --headless -r 0.1 -u $NUM_CLIENTS1 -t 23m -s 5s &
  locust -f robot-shop.py --host "$HOST" --headless -r 2 -u $NUM_CLIENTS2 -t 11m -s 5s &
  locust -f robot-shop.py --host "$HOST" --headless -r 0.05 -u $NUM_CLIENTS3 -t 19m -s 5s

done