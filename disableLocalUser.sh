#!/usr/bin/env bash

# This script disables, deletes, and/or archives users on the system.

# Creating variable to represent the /archive dir
ARCHIVE_DIR='/archive'

usage() {
  # Display the usage and exit.
  echo "Usage: ${0} [-dra] USER [USERNAME]...">&2
  echo 'Disable a local Linux account' >&2
  echo ' -d Deletes accounts instead of disabling them.' >&2
  echo ' -r Removes the home directory associated with the account(s).' >&2
  echo ' -a Creates an archive of the home directory associated with the account(s).' >&2
  exit 1
}

# Root check

if [[ "${EUID}" -ne 0 ]]
then
  echo "You must be root to do this." >&2
  exit 1
fi

# Parse the options.

while getopts dra OPTION
do
  case ${OPTION} in
    d) DELETE_USER='true' ;;
    r) REMOVE_OPTION='-r' ;;
    a) ARCHIVE='true' ;;
    ?) usage ;;
  esac
done

# Remove the options while leaving the remaining arguments.
shift "$(( OPTIND - 1))"

# If the user doesn't supply at least one argument, display the proper usage.
if [[ "${#}" -eq 0 ]]
then
  usage
fi

# loop through all the usernames supplied as arguments.
for USERNAME in "${@}"
do
  echo "User: ${USERNAME}"

  # Make sure the UID of the account is at least 1000
  USERID=$(id -u ${USERNAME})
  if [[ "${USERID}" -lt 1000 ]]
  then
  echo "You can't remove ${USERNAME} with UID ${USERID} because the UID is below 1000!" >&2
  exit 1
fi

# Create an archive if -a is specified
if [[ "${ARCHIVE}" = 'true' ]]
then
  # Make sure that the /archive directory exists
  if [[ ! -d "${ARCHIVE_DIR}" ]]
  then
    echo "Creating ${ARCHIVE_DIR} directory."
    mkdir -p ${ARCHIVE_DIR}
    if [[ "${?}" -ne 0 ]]
    then
      echo "The archive directory ${ARCHIVE_DIR} could not be created." >&2
      exit 1
    fi
  fi

  # Archive the user's home directory and move it into the /archive directory
  HOME_DIR="/home/${USERNAME}"
  ARCHIVE_FILE="${ARCHIVE_DIR}/${USERNAME}.tgz"
  if [[ -d "${HOME_DIR}" ]]
  then
    echo "Archiving ${HOME_DIR} to ${ARCHIVE_FILE}"
    tar -zcf ${ARCHIVE_FILE} ${HOME_DIR} &> /dev/null
    if [[ "${?}" -ne 0 ]]
    then
      echo "Could not create ${ARCHIVE_FILE}." >&2
      exit 1
    fi
  else
    echo "${HOME_DIR} does not exist or is not a directory." >&2
    exit 1
  fi
fi

if [[ "${DELETE_USER}" = 'true' ]]
then
  # Delete the user(s)
  userdel ${REMOVE_OPTION} ${USERNAME}

  # Check to see if the userdel command succeeded.
  if [[ "${?}" -ne 0 ]]
  then
    echo "The account ${USERNAME} was not deleted." >&2
    exit 1
  fi
  echo "The account ${USERNAME} was deleted."
else
  chage -E 0 ${USERNAME}
  # Check to see if the chage command succeeded.
  if [[ "${?}" -ne 0 ]]
  then
    echo "The account ${USERNAME} was not disabled." >&2
    exit 1
  fi
  echo "The account ${USERNAME} was disabled."
fi
done

exit 0
