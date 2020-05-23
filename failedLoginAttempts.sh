#!/usr/bin/env bash

# Count the number of failed logins by IP address.
# If there are any IP addresses over 10 failures, display the count, IP, and location.

LOG_FILE="${1}"

# Verify a file was supplied as an argument
if [[ ! -e "${LOG_FILE}" ]]
then
  echo "Cannot open log file: ${LOG_FILE}" >&2
  exit 1
fi

# Display the CSV header
echo 'Count,IP,Location'

# Loop through the list of failed attempts and the corresponding IP addresses.
grep Failed syslog-sample | awk '{print $(NF - 3)}' | sort | uniq -c | sort -nr | while read COUNT IP
do
  # If the number of failed attempts is greater than 10, display the count, IP, and location.
  if [[ "${COUNT}" -gt 10 ]]
  then
    LOCATION=$(geoiplookup ${IP} | awk -F ', ' '{print $2}')
    echo "${COUNT},${IP},${LOCATION}"
  fi
done
exit 0
