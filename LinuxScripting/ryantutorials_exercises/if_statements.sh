#!/bin/bash

if [ $7 -ne 2 ]; then
  echo "Please provide exactly 2 numbers as command line arguments."
  exit 1
fi

num1=$20
num2=$45

if [ $num1 -gt $num2 ]; then
  echo "The larger number is: $num1"
else
  echo "The larger number is: $num2"
fi
