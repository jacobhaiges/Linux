# Shell Script Goal

[This shell script](../localUserCreation.sh) is supposed to make new user accounts based on provided input.

# Shell Script Requirments

* Must be executed with root privileges. If it is not, a user will not be created and it will return an exit status of 1.
* Prompts for a username, full name, and an initial password.
* Creates a user with the input provided.
* If the account was not successfully created, inform the user and and return an exit status of 1.
* Display the username & password along with the host where the account was created.

# VM Creation
(Skip this step if you know how to setup the Vagrant VM)
From the setup, use an existing Vagrant project directory or make a new one. I'm going to make a new folder.
```
mkdir shellScripts
cd shellScripts
vagrant init jasonc/centos7
```
As before, you can change the Vagrantfile config and customize the hostname:
```
config.vm.hostname = "shellScripts"
```
To launch up the VM:
```
vagrant up
vagrant ssh
```
Navigate to the shared /vagrant directory:
```
cd /vagrant
```
# Writing the Shell Script

I'm going to use Atom to write the shell script but you can use whatever text editor you prefer.

To make the purpose of this script clear, I'm going to use comments detailing what a line is supposed to do.

Create a .sh file in the /vagrant directory:
```
touch localUserCreation.sh
```
Now open it in a text editor.

Make sure you include the following at the top of the script:
```
#!/usr/bin/env bash
```
Note: it's not always going to necesarrily be the same path following the shebang (#!). It might be #!/bin/bash/ instead

I've added comments on the .sh script detailing all of the requirements to make sure they're all covered, it isn't required but I would highly recommend doing so.

* [If statement help](https://ryanstutorials.net/bash-scripting-tutorial/bash-if-statements.php)

I started with checking that the script was executed by root by using an if statement:
```
if [[ "${EUID}" -ne 0 ]]
then
  echo "You must be root to do this."
  exit 1
fi
```
The root account has an EUID of 0, so this script is saying that if the EUID is not 0, then tell the user
and exit with a status code of 1.

* [Reading input help](https://ryanstutorials.net/bash-scripting-tutorial/bash-input.php)

Next, I prompted for a username, full name, and an initial password:
```
read -p 'Username: ' USERNAME
read -p 'Full Name: ' COMMENT
read -p 'Password: ' PASSWORD
```
This block of code will prompt the user for the 3 fields on seperate lines and store the corresponding answer
in the variables on the right hand side.

* [Useradd help](https://ss64.com/bash/useradd.html)

Creating a user with the input provided:
```
useradd -c "{COMMENT}" -m ${USERNAME}
```
This block of code is using the -c switch which is commonly used to represent a full name, -m will create the users' home directory if it does not exist, and the username value that the user entered is used as the username.

* [Checking if previous command worked](https://askubuntu.com/questions/29370/how-to-check-if-a-command-succeeded)

To help the user know whether or not it worked, I added a section that checks whether the last command was executed successfully be checking the exit status code. An exit status code of 0 means that it ran without any errors.
```
if [[ "${?}" -ne 0 ]]
then
  echo 'User account was not created'
  exit 1
else
  echo 'User account was successfully created'
fi
```

Next, passwd has a --stdin switch so I echoed the password variable to the console and piped that to passwd --stdin with the corresponding username value.

```
echo ${PASSWORD} | passwd --stdin ${USERNAME}
```

Again, I am checking the previous command to see if the password was set successfully.
```
if [[ "${?}" -ne 0 ]]
then
  echo 'The password for the account could not be set.'
  exit 1
fi
```

As per the requirements, the user is supposed to be forced to change their password upon first login. This can be accomplished with the -e switch which forces a user to change their password at next login.
```
passwd -e ${USERNAME}
```

Finally, the requirements said to print out the username, password, and host where the account was created. This can be accomplished using simple echo statements. The exit 0 status code is to mark that the command ran without error.
```
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
```

To use the script:
```
./localUserCreation.sh
```

# Sample output

```
./localUserCreation.sh
```

```
Username: mjackson
Full Name: Michael Jackson
Password: owlMoon
User account was successfully created
Changing password for user mjackson.
passwd: all authentication tokens updated successfully.
Expiring password for user mjackson.
passwd: Success

username:
mjackson

password:
owlMoon

host:
localhost.localdomain
```

To verify, let's log onto the new account.
```
[vagrant@localhost vagrant]$ su - mjackson
Password:
You are required to change your password immediately (root enforced)
Changing password for mjackson.
(current) UNIX password:
New password:
Retype new password:
Last failed login: Tue May  5 21:28:54 EDT 2020 on pts/0
There was 1 failed login attempt since the last successful login.
[mjackson@localhost ~]$
```
That wraps up testing, the script executed with no errors and met all the requirements.
