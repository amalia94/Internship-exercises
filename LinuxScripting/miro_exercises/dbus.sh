#!/bin/bash

charging_status=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E "state|percentage" | awk '{print $2}')

if [ "$charging_status" == "charging" ] || [ "$charging_status" == "fully-charged" ]; then
    echo "This machine is currently plugged in"
else
    echo "This machine is currently using the battery"
fi


#function
