# Shell Scripting

The goal is this project is to gain some experience with the Linux command line and shell scripting, and document the steps that I took.

# Target Audience
The target audience for this tutorial is someone who has basic Linux CLI experience.

# Labs

# [Prerequisites](docs/01-prerequisites.md)
This project is about shell scripting which means you need either a Linux based operating system installed, or alternatively, you can use a virtual machine like I'm doing. I decided to use [Vagrant](https://www.vagrantup.com/downloads.html) to set up the virtual machines because it was a new technology to learn and you can set up / tear down virtual machines quickly without fear of messing anything up.

# [Setting up Vagrant VM](docs/02-setup.md)
Vagrant enables users to create and configure lightweight, reproducible, and portable development environments. If you would like to use Vagrant check out this document as I explain the process from installing Vagrant to connecting to your first virtual machine created using Vagrant. 

# [Creating Local Users Script](docs/03-localUserScript.md)
This shell script covers important scripting concepts such as: if statements, reading input, checking the exit status of the previous command, and more. The goal of this script is to create local users based on input that the script prompts the user for.

# [Creating Local Users Script Version 2](docs/04-localUserScript_v2.md)
This shell script improves on the previous script by introducing the ability to provide the input as an argument to the script all in one line, in addition to randomly generating a password that expires upon first login.

# [Creating Local Users Script Version 3](docs/05-localUserScript_v3.md)
This shell script is more user friendly than the previous script and introduces the concept of sending error messages to standard error, and reducing the screen clutter from running the script by sending some output to the null device.

# [Deleting Local Users Script](docs/06-disableLocalUser.md)
This shell script introduces the usage of functions, flags, and parsing command options with getopts. The goal of this script is to disable, delete, or archive an account depending on the flags set when executing the script.

# [Failed Login Attempts Script](docs/07-failedLoginAttempts.md)
This shell script uses various command line utilities (grep, awk, uniq, sort) to match a regular expression (IP address) and filter the output into an easily readable .csv format.

# [Configuring Multi-System Network](docs/08-multiNetworkSetup.md)
The next script simulates a multiple server network and this document covers the configuration of a multi-system network using Vagrant. Additionally, this document covers a script that is designed to test the connectivity of a list of servers.

# [Execute Command on Multiple Servers Script](docs/09-execCmdMultipleServers.md)
This shell script incorporates a ton of shell scripting concepts: functions, if statements, while loops, parsing options, for loops, and using flags. The goal of this script is to execute a given command on multiple servers.

