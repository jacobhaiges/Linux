#!/usr/bin/env bash

# Root check

if [[ "${EUID}" -ne 0 ]]
then
  echo "You must be root to do this." >&2
  exit 1
fi

# Atleast 1 parameter check & usage information. All information with this event will be displayed on STDERR.

if [[ "$#" -eq 0 ]]
then
  echo "The correct format is ./localUserCreation_v3 USERNAME [Comment]" >&2
  exit 1
fi

# First argument is the username for the account.

declare USERNAME=$1

# Any additional arguments are treated as comments.

shift
declare COMMENT=$@

# Generating a secure password

declare PASSWORD=$(date +%N | sha256sum | head -c18)

# Creating a user with the username / password given

useradd -c "${COMMENT}" -m ${USERNAME} &> /dev/null

# useradd status check

if [[ "${?}" -ne 0 ]]
then
  echo 'The account could not be created.' >&2
  exit 1
fi

# Setting the password

echo ${PASSWORD} | passwd --stdin ${USERNAME} &> /dev/null

# passwd status check

if [[ "${?}" -ne 0 ]]
then
  echo 'The password for the account could not be set.' >&2
  exit 1
fi

# Forced PW change

passwd -e ${USERNAME} &> /dev/null

# displaying the username, password, and the host

echo 'username: '
echo "${USERNAME}"
echo
echo 'password: '
echo "${PASSWORD}"
echo
echo 'host: '
echo "${HOSTNAME}"
