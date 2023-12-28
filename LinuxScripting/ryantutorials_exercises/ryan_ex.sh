#!/bin/bash
echo Hello again!
var1="HELLO"
var2="AGAIN!"
echo "$var1 $var2"
name="$1"
echo "Hello $name"
name="Merry Christmas!"
location=$(pwd)
code="name"

echo "Merry Christmas!"
sleep 1
echo "You are in this place $location!"
sleep 2
echo "Your code is $code"


echo "Merry Christmas!"
sleep 7
echo "Your code is this: $code."


echo "The number of seconds since the script was started is: $SECONDS"

echo "This variable returns a different random number each time is it refferd to $RANDOM"

echo "The number of arguments were passed to the bash script is: $@"

echo "The name of the bash script is: $0"

echo "The hostname of the machine the script is running on is: $HOSTNAME"


