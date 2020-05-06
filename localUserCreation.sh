#!/usr/bin/env bash

# Must be executed with root privileges, if not, exit with a status of 1.

if [[ "${EUID}" -ne 0 ]]
then
  echo "You must be root to do this."
  exit 1
fi

# Prompts for a username, full name, and an initial password

read -p 'Username: ' USERNAME
read -p 'Full Name: ' COMMENT
read -p 'Password: ' PASSWORD

# Creates a user with the input provided
useradd -c "{COMMENT}" -m ${USERNAME}

# If the user account was successfully created, inform the user and return an exit status of 1.

if [[ "${?}" -ne 0 ]]
then
  echo 'User account was not created'
  exit 1
else
  echo 'User account was successfully created'
fi

# Set the password and verify it was set correctly

echo ${PASSWORD} | passwd --stdin ${USERNAME}

if [[ "${?}" -ne 0 ]]
then
  echo 'The password for the account could not be set.'
  exit 1
fi

# Force password change on first login

passwd -e ${USERNAME}

# Display the username & password along with the host where the account was created

echo
echo 'username: '
echo "${USERNAME}"
echo
echo 'password: '
echo "${PASSWORD}"
echo
echo 'host: '
echo ${HOSTNAME}
echo
exit 0
