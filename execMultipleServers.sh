#!/usr/bin/env bash

# List of servers
SERVER_LIST='/vagrant/servers'

# Options for the ssh command
SSH_OPTIONS='-o ConnectTimeout=2'

usage() {
  # Display the proper usage
  echo "Usage: ${0} [-nsv] [-f FILE] COMMAND" >&2
  echo "Executes COMMAND as a single command on every server."
  echo " -f FILE   Use FILE for the list of servers. Default ${SERVER_LIST}." >&2
  echo " -n        Test run mode. Display the COMMAND that would have been executed without actually executing
  them." >&2
  echo " -s        Execute the COMMAND with root privileges on the remote server." >&2
  echo " -v        Verbose mode. Displays the server name before executing COMMAND." >&2
  exit 1
}

# Verify the script is not being executed with root privileges
if [[ "${UID}" -eq 0 ]]
then
  echo 'You cannot execute this script as root by default. Confirm you want to execute this script as root and use
  the -s option to do so.' >&2
  usage
fi

# Parse options
while getopts f:nsv OPTION
do
  case ${OPTION} in
    f) SERVER_LIST="${OPTARG}" ;;
    n) TEST_RUN='true' ;;
    s) SUDO='sudo' ;;
    v) VERBOSE='true' ;;
    ?) usage ;;
  esac
done

# Shift over the options and leave remaining arguments
shift "$(( OPTIND -1 ))"

# If the user doesn't supply at least one argument, display the usage
if [[ "${#}" -lt 1 ]]
then
  usage
fi

# Anything that remains on the command line after being shifted is to be treated as a single command
COMMAND="${@}"

# Make sure that the SERVER_LIST file exists
if [[ ! -e "${SERVER_LIST}" ]]
then
  echo "Cannot open server list file ${SERVER_LIST}." >&2
  exit 1
fi

# A command that successfully runs will exit with an exit status of 0
S_EXIT_STATUS='0'

# Loop through the server list file
for SERVER in $(cat ${SERVER_LIST})
do
  if [[ "${VERBOSE}" = 'true' ]]
  then
    echo "${SERVER}"
  fi

  SSH_COMMAND="ssh ${SSH_OPTIONS} ${SERVER} ${SUDO} ${COMMAND}"

  # If it's a test run, don't execute anything
  if [[ "${TEST_RUN}" = 'true' ]]
  then
    echo "TEST RUN: ${SSH_COMMAND}"
  else
    ${SSH_COMMAND}
    S_EXIT_STATUS="${?}"

    # If the exit status if anything other than 0, inform the user
    if [[ "${S_EXIT_STATUS}" -ne 0 ]]
    then
      EXIT_STATUS="${S_EXIT_STATUS}"
      echo "Command execution on ${SERVER} failed." >&2
    fi
  fi
done

exit ${EXIT_STATUS}
