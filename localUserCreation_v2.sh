#!/usr/bin/bash

# This script creates a new user on the local system.
# You must supply a username as an argument to the script.
# Optionally, you can also provide a comment for the account as an argument.
# A password will be automatically generated for this account.
# The username, password, and host for the account will be displayed.
# Must be executed with root privileges, if not, exit with a status of 1.

if [[ "${EUID}" -ne 0 ]]
then
  echo "You must be root to do this."
  exit 1
fi

# If the user doesn't supply at least one argument, then give them help.

if [[ "$#" -eq 0 ]]
then
  echo "The correct format is ./localUserCreation_v2 USERNAME [Comment]"
  exit 1
fi

# The first parameter is the user name.

declare USERNAME=$1

# The rest of the parameters are for the account comments.

shift
declare COMMENT=${@}

# Generate a secure password

declare PASSWORD=$(date +%N | sha256sum | head -c18)

# Create a user with the username/password given

useradd -c "${COMMENT}" -m ${USERNAME}

# Check to see if the useradd command succeeded

if [[ "${?}" -ne 0 ]]
then
  echo 'The account could not be created.'
  exit 1
fi

# Set the password

echo ${PASSWORD} | passwd --stdin ${USERNAME}

# Check to see if the passwd command succeeded
if [[ "${?}" -ne 0 ]]
then
  echo 'The password for the account could not be set.'
  exit 1
fi

# Force password change on first login.
passwd -e ${USERNAME}

# Display the username, password, and the host where the user was created.
echo
echo 'username: '
echo "${USERNAME}"
echo
echo 'password: '
echo "${PASSWORD}"
echo
echo 'host: '
echo "${HOSTNAME}"
