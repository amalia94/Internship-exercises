#!/bin/bash

# Prompt the user for information
read -p "Please enter your name: " name
read -p "Please enter your age: " age
read -p "Please enter your location: " location

# Combine the information into a message
message="Hello, $name! You are $age years old and located in $location."

# Display the message on the screen
echo $message
