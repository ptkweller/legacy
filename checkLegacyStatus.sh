#!/bin/bash

##
# Declare variables
##
legacyHome="/data/legacy/"
responseCode=`curl -I -X GET http://127.0.0.1:17873/ | head -n 1 |cut -d$' ' -f2`

if [ "${responseCode}" == "500" ]
then
  ## Kill process and start.
  echo "Stopping legacy App."
  ps -ef | grep legacy | grep -v grep | awk '{print $2}' | xargs kill  
  sleep 3s
  
  echo "Starting legacy App."
  cd ${legacyHome}
  ./legacy "" &

elif [ "${responseCode}" != "202" ]
then
  ## Start legacy App
  echo "Starting legacy App."
  cd ${legacyHome}
  ./legacy "" &

fi
