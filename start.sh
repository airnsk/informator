#!/bin/bash

if pidof linphonec; then
   pidlin=$(pidof linphonec)
   echo kill linphonec
   kill -2 $pidlin
   sleep 5
   if pidof linphonec; then
   pidlin = pidof linphonec
   kill -9 $pidlin
   fi
fi

while :
do
echo loop 
./robotmysql.sh
sleep 30
done
