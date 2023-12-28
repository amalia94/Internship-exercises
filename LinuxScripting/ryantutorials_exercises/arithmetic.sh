#!/bin/bash

#Create a simple script which will take two command line arguments
#and then multiply them together using each of the methods detailed above.

a=$(( 7 + 7 ))
echo $a

b=$(( a + 10 ))
echo $b


#Write a Bash script which will print tomorrows date.


tomorrow=$(date -d "+1 day" +%Y-%m-%d)
echo "Tomorrow's date is: $tomorrow"

