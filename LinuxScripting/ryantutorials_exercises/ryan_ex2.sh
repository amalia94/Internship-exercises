#!/bin/bash

#create a script which will print a random word  # hint: Piping

#shuf -n 1 listacuvinte.txt | head -n 1

sed '3!d' listacuvinte.txt

#lastCommand=$(echo `history |tail -2 |head -n1` | sed 's/[0-9]* //')

#grep command

grep craciun listacuvinte.txt

