# Shell Script Goal
This shell script is supposed to make new user accounts and accepts given parameters.
# Shell Script Requirements
* Must be executed with root privileges. If it is not, a user will not be created and it will return an exit status of 1.
* Provides a usage statement similar to a man page if the user does not supply an account name on the command line & returns an exit status of 1.
* Uses the first argument provided on the command line as the username for the account. Any additional arguments on the command line will be treated as the comment for the account.
* Automatically generates a secure password for the new account.
* Informs the user if the account was not able to be created. If the account is not created, the script is to return an exit status of 1.
* Display the username, password, and host where the account was created.``
# Writing the Shell Script

I'm going to start by creating the script in the /vagrant directory:
```
touch localUserCreation_v2.sh
```
To begin, the script is going to start by pointing to the interpreter.
```
#!/usr/bin/env bash
```
Next, checking that it was executed as root:
```
if [[ "${EUID}" -ne 0 ]]
then
  echo "You must be root to do this."
  exit 1
fi
```
Checking to see if the user supplied at least one argument (for the username), if not, give them help.
```
if [[ "$#" -eq 0 ]]
then
  echo "The correct format is ./localUserCreation_v2 USERNAME [Comment]"
  exit 1
fi
```
The variable
```
"$#"
```
is the number of parameters supplied to the command line, and this statement is testing if there wasn't any parameters supplied. If no parameters are given, it prints out the correct usage of the command.

Assigning the first parameter as the username:
```
declare USERNAME=$1
```
Any remaining parameters are to be the account comments:
```
shift
declare COMMENT=$@
```
The variable
```
"$@"
```
covers all the remaining arguments entered.

Generating a secure password:
```
declare PASSWORD=$(date +%N | sha256sum | head -c18)
```
This is assigning the variable PASSWORD to date +%N piped to sha256sum piped to head -c18 to take only 18 characters as the password.

Creating a user with the username / password given:
```
useradd -c "${COMMENT}" -m ${USERNAME}
```
Checking to see if the useradd command succeeded:
```
if [[ "${?}" -ne 0 ]]
then
  echo 'The account could not be created.'
  exit 1
fi
```

Setting the password:
```
echo ${PASSWORD} | passwd --stdin ${USERNAME}
```

Checking to see if the passwd command succeeded:
```
if [[ "${?}" -ne 0 ]]
then
  echo 'The password for the account could not be set.'
  exit 1
fi
```

Forcing a password change on first login:
```
passwd -e ${USERNAME}
```

Display the username, password, and the host where the user was created:
```
echo
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
./localUserCreation_v2.sh jhaiges Jacob Haiges
```
The first parameter
```
jhaiges
```
is the username for the account.
Anything after that is used as the comment, which in my case is:
```
Jacob Haiges
```
Sample output:
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
Verifying the password expiration:
```
[vagrant@localhost vagrant]$ su - jhaiges
Password:
You are required to change your password immediately (root enforced)
Changing password for jhaiges.
(current) UNIX password:
New password:
Retype new password:
[jhaiges@localhost ~]$
```
Testing is finished, the script executes as intended and met all the requirements.
