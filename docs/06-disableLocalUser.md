# Shell Script Goal
This shell script deletes, disables, and/or archives users on the local system.

# Shell Script Requirements
* Must be executed with root privileges. If it is not, a user will not be created and it will return an exit status of 1.
* Provides a usage statement similar to a man page if the user does not supply an account name on the command line & returns an exit status of 1. All the messages associated with this event will be displayed on standard error (STDERR).
* Disables accounts by default.
* Allows the user to specify various options:
  * -d Deletes accounts instead of disabling them.
  * -r Removes the home dir associated with the account.
  * -a Creates an archive of the home dir associated with the account. Stores the archive in the
  /archives directory. (NOTE: /archives is not a default directory that exists on a Linux system. This script should create the /archive directory if it does not already exist.)
  * Any other option isn't valid and therefore should cause the script to display a usage statement along with exiting with an exit status of 1.
  * Accepts a list of usernames as arguments. One username is required by default, if not, the script will display a proper usage statement like you would find in a man page and return an exit status of 1. All the messages associated with this event will be displayed on standard error (STDERR).
  * Will not disable or delete any accounts that have a UID of less than 1,000. (NOTE: This is because accounts with a UID under 1000 are typically system accounts. Careful consideration should be taken before deleting one of these accounts as it can have serious effects on the system.)
  * Informs the user if the account was not able to be disabled, deleted, or archived.
  * Displays the username and any actions performed against the account.

# Writing the Shell Script

Starting the script:
```
touch disableLocalUser.sh
```
Pointing to the interpreter:
```
#!/usr/bin/env bash
```
This time, I'm going to create a usage function to showcase how functions work in shell scripting. The goal of using a function is to break down the functionality of a script into a smaller section that can be called upon to perform individual tasks. Functions are particularly useful if you have a recurring code block to avoid having the same large code block in multiple spots throughout the script. [For more information on function usage and syntax](https://www.tutorialspoint.com/unix/unix-shell-functions.htm). Let's create the usage function that shows the user the command usage and options:
```
usage() {
  # Display the usage and exit.
  echo "Usage: ${0} [-dra] USER [USERNAME]...">&2
  echo 'Disable a local Linux account' >&2
  echo ' -d Deletes accounts instead of disabling them.' >&2
  echo ' -r Removes the home directory associated with the account(s).' >&2
  echo ' -a Creates an archive of the home directory associated with the account(s).' >&2
  exit 1
}
```
This will show the user the valid command flags, how to use the script, and the function of it. Now to check for root privileges:
```
if [[ "${EUID}" -ne 0 ]]
then
  echo "You must be root to do this." >&2
  exit 1
fi
```
Next step is to parse the options to perform the proper action depending on the flag specified. I'm going to use the built-in
```
getopts
```
function to do this. [For more information on getopts.](https://sookocheff.com/post/bash/parsing-bash-script-arguments-with-shopts/) Additionally, I'm going to use a while loop to cycle through any options specified.
```
while getopts dra OPTION
do
  case ${OPTION} in
    d) DELETE_USER='true' ;;
    r) REMOVE_OPTION='-r' ;;
    a) ARCHIVE='true' ;;
    ?) usage ;;
  esac
done
```
This code block is using a
```
[case]
```
[statement](https://www.shellscript.sh/case.html) to avoid going through a bunch of if/else statements. The last ? acts as a sort of "catch all" to call the usage function if an option that isn't listed is called.
Next I'm going to remove the options specified while leaving the remaining arguments, which in this case, is going to be the username of the account.
```
shift "$(( OPTIND - 1))"
```
This statement is going to pass the command the next command line argument. [More information](https://unix.stackexchange.com/questions/214141/explain-the-shell-command-shift-optind-1/214151)
Now I'm going to check that atleast 1 argument was supplied, if not, display the usage using the usage() function that was defined at the top of the script.
```
if [[ "${#}" -eq 0 ]]
then
  usage
fi
```
Looping through all the usernames supplied as arguments and printing them:
```
for USERNAME in "${@}"
do
  echo "User: ${USERNAME}"
  ```
Making sure the UID of the account is atleast 1000 as per the requirements:
```
USERID=$(id -u ${USERNAME})
if [[ "${USERID}" -lt 1000 ]]
then
echo "You can't remove ${USERNAME} with UID ${USERID} because the UID is below 1000!" >&2
exit 1
fi
```
The UID is checked using the [id command](https://linuxize.com/post/id-command-in-linux/).
Creating an archive if the -a flag is specified:
```
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
```
The -a flag sets the archive variable to true, which in turn will first check to see if the /archive directory already exists. If it does not, then it will create it. If the /archive directory could not be created, the script informs the user.
Next is actually archiving the user's home directory and moving it into the /archive directory:
```
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
```
This code block is creating an archive of the user's home directory by using the
```
tar
```
command. The zcf flags will create a compressed gzip archive with the format ${ARCHIVE_DIR}/${USERNAME}.tgz". 
* [Tar examples](https://www.tecmint.com/18-tar-command-examples-in-linux/)
* [Tar man page](https://linux.die.net/man/1/tar) \
The code block for the delete user option:
```
if [[ "${DELETE_USER}" = 'true' ]]
then
  # Delete the user(s)
  userdel ${REMOVE_OPTION} ${USERNAME}
```
This code block is using the [userdel](https://linux.die.net/man/8/userdel) command to delete the user's home directory. Checking if the userdel command succeeded:
```
if [[ "${?}" -ne 0 ]]
then
  echo "The account ${USERNAME} was not deleted." >&2
  exit 1
fi
echo "The account ${USERNAME} was deleted."
else
chage -E 0 ${USERNAME}
```
The [chage](https://linux.die.net/man/1/chage) command will disable the account if the user does not specify they want to delete the user completely. The last thing to do is check if the chage command succeeded to disable the account:
```
if [[ "${?}" -ne 0 ]]
then
  echo "The account ${USERNAME} was not disabled." >&2
  exit 1
fi
echo "The account ${USERNAME} was disabled."
fi
done

exit 0
```
If the script runs with no errors, it will exit with an exit status code of 0.
# Sample Output
# Default
Using the script with no flags example:
```
./disableLocalUser.sh emusk
```
Output:
```
User: emusk
The account emusk was disabled.
```
# -d flag
Running the script with the -d flag:
```
./disableLocaluser.sh -d emusk
```
Output:
```
User: emusk
The account emusk was deleted.
```
# -r flag
Running the script with the -r option:
```
./disableLocalUser.sh -r emusk
```
Output:
```
User: krool
The account krool was disabled.
```
# -a flag
Running the script with the -a flag:
```
./disableLocalUser.sh -a bross
```
Output:
```
User: bross
Archiving /home/bross to /archive/bross.tgz
The account bross was disabled.
```
# -da flags
Running the script with the -da flags:
```
./disableLocalUser.sh -da mmiller
```
Output:
```
User: mmiller
Archiving /home/mmiller to /archive/mmiller.tgz
The account mmiller was deleted.
```
# -ra flags
Running the script with the -ra flags:
```
./disableLocalUser.sh -ra bbob
```
Output:
```
User: bbob
Archiving /home/bbob to /archive/bbob.tgz
The account bbob was disabled.
```
# Final Thoughts
There is room for improvement on this script, but it covers the usage of important aspects of shell scripting:
Using command flags, displaying the usage of commands, using getopts, using functions, creating a "log" file (in this case, an archive file of user's /home directory).
