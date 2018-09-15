#!/bin/bash

if [ "${operation}" == "create" ]
then
  terraform init
  terraform plan -out main.plan
  terraform apply main.plan
  publicIP=`terraform show | grep "public_ip = " | cut -d ' ' -f 5`
  echo " "
  echo "Webserver can be accessed http://${publicIP}:17873/"
  echo " "
  echo "NOTE: webserver may take a few minutes to start."

elif [ "${operation}" == "destroy" ]
then
  terraform destroy -auto-approve

fi
