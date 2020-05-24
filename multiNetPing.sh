#!/usr/bin/env bash

# This script pings a list of servers and reports on their status.

SERVER_FILE='/vagrant/servers'
# Server file contains:
# server01
# server02

if [[ ! -e "${SERVER_FILE}" ]]
then
  echo "Cannot open ${SERVER_FILE}." >&2
  exit 1
fi

for SERVER in $(cat ${SERVER_FILE})
do
  echo "Pinging ${SERVER}"
  ping -c 3 ${SERVER} &> /dev/null
  if [[ "${?}" -eq 0 ]]
  then
    echo "${SERVER} up."
  else
    echo "${SERVER} down."
  fi
done
