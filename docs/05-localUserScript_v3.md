# Shell Script Goal
This shell script is supposed to make new user accounts, accept parameters, and add redirection.
* Note: This script is very similar to the [localUserCreation_v2](docs/04-localUserScript_v2.md) script. The
difference is that this script is redirecting output for less screen clutter.

# Shell Script Requirements
* Must be executed with root privileges. If it is not, a user will not be created and it will return an exit status of 1.
* Provides a usage statement similar to a man page if the user does not supply an account name on the command line & returns an exit status of 1. All the messages associated with this event will be displayed on standard error (STDERR).
* Uses the first argument provided on the command line as the username for the account. Any additional arguments on the command line will be treated as the comment for the account.
* Automatically generates a secure password for the new account.
* Informs the user if the account was not able to be created. If the account is not created, the script is to return an exit status of 1.
* Display the username, password, and host where the account was created.``
* Suppress the output from all other commands

# Writing the Shell Script

Starting the script:
```
touch localUserCreation_v3.sh
```
Pointing to the interpreter:
```
#!/usr/bin/env bash
```
Checking to see if the script was executed as root and redirecting the output to standard error.
```
if [[ "${EUID}" -ne 0 ]]
then
  echo "You must be root to do this." >&2
  exit 1
fi
```
The
```
>&2
```
you see in the code block above is using ">" which is normally [redirecting](https://www.gnu.org/software/bash/manual/html_node/Redirections.html) the standard input, but instead, the &2 after is redirecting both standard output AND standard error.
* Note: File Descriptor 1 = Standard Input
* File Descriptor 2 = Standard output (there is an implicit 1 when using >, unless specified otherwise) |
* File Descriptor 3 = Standard Error

Checking to see if there was atleast 1 parameter supplied. If not, provide the command usage information. If there isn't any parameters given, display the message to STDERR.
```
if [[ "$#" -eq 0 ]]
then
  echo "The correct format is ./localUserCreation_v3 USERNAME [Comment]" >&2
  exit 1
fi
```
Use first parameter as the username:
```
declare USERNAME=$1
```
Any additional parameters are treated as the comments for the account:
```
shift
declare COMMENT=$@
```
Generating a secure password:
```
declare PASSWORD=$(date +%N | sha256sum | head -c18)
```
Creating a user with the username / password given, and redirecting the STDOUT and STDERR of useradd to []/dev/null](https://askubuntu.com/questions/12098/what-does-outputting-to-dev-null-accomplish-in-bash-scripts). /dev/null essentially discards all information written to it, meaning there is no output from the useradd command.
```
useradd -c "${COMMENT}" -m ${USERNAME} &> /dev/null
```
Checking the useradd status and redirecting the output to standard error:
```
if [[ "${?}" -ne 0 ]]
then
  echo 'The account could not be created.' >&2
  exit 1
fi
```
Setting the password and redirecting all of the output to /dev/null:
```
echo ${PASSWORD} | passwd --stdin ${USERNAME} &> /dev/null
```
Checking the status of the passwd command and redirecting all of the output to standard error.
```
if [[ "${?}" -ne 0 ]]
then
  echo 'The password for the account could not be set.' >&2
  exit 1
fi
```
Forcing a password change upon first login:
```
passwd -e ${USERNAME} &> /dev/null
```
Displaying the username, password, and the host:
```
echo 'username: '
echo "${USERNAME}"
echo
echo 'password: '
echo "${PASSWORD}"
echo
echo 'host: '
echo "${HOSTNAME}"
```
Using the script example:
```
./localUserCreation_v3.sh emusk Elon Musk
```
The username is
```
emusk
```
and the comment for the account is
```
Elon Musk
```
Sample output (notice the difference from the previous localUserCreation_v2.sh):
```
[vagrant@localhost vagrant]$ sudo ./localUserCreation_v3.sh emusk Elon Musk
username:
emusk

password:
659bc787adbf1dc466

host:
localhost.localdomain
```
Compared to the output from last time, you'll notice a few changes:
```
[vagrant@localhost vagrant]$ sudo ./localUserCreation_v2.sh jhaiges Jacob Haiges
Changing password for user jhaiges.
passwd: all authentication tokens updated successfully.
Expiring password for user jhaiges.
passwd: Success

username:
jhaiges

password:
914d3450bcb61c8f1b

host:
localhost.localdomain
```
The system messages that tell you the password is being changed, the authentication tokens updated successfully, and the password expiration are all suppressed and not sent to standard output.

This script met all of the requirements and improved on the [previous script](docs/04-localUserScript_v2.md) by reducing the clutter and making it more user-friendly.
