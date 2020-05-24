# Shell Script Goal
This shell script executes a given command on multiple servers.

# Shell Script Requirements
* Executes all arguments as a single command on every server listed in the /vagrant/servers file by default.
* Executes the provided command as the user executing the script.
* Uses "ssh -o ConnectTimeout=2" to connect to a host.  If a host is down, the script won't wait more than 2 seconds per down server.
* Allow the user to specify the following options:
  * -f This allows the user to override the default file of /vagrant/servers. This will allow the user to use their own list of servers for use with this command.
  * -n This allows to perform a "test run" where commmands are displayed rather than executed. Each command that would have been executed should be preceded with "TEST RUN: ".
  * -s Run the command with sudo privileges on the remote servers.
  * -v Enable verbose mode, which will display the name of the server for which the command is being executed on.
* Must be executed without root privileges. If the user wants the remote commands to be executed with root privileges, they must specify the -s option.
* Provides a usage statement similar to a man page if the user does not supply an account name on the command line & returns an exit status of 1. All the messages associated with this event will be displayed on standard error (STDERR).
* Informs the user if the command was not able to be executed successfully on a remote host.
* Exits with an exit status of 0 or the most recent non-zero exit status of the ssh command.

# Config
I am going to be using the config from doc08, [configuring a multiple system network](docs/08-multiNetworkSetup.md). Refer to this document for the configuration for this script to function properly.

# Writing the Shell Script
Starting the script:
```
touch execMultipleServers.sh
```
Pointing to the interpreter:
```
#!/usr/bin/env bash
```
Pointing the script to the default server list file location:
```
SERVER_LIST='/vagrant/servers'
```
Setting the ssh timeout to 2 seconds so if a host is down, the script won't wait more than 2 seconds before moving on:
```
SSH_OPTIONS='-o ConnectTimeout=2'
```
The next code block is creating a usage function to showcase how functions work in shell scripting The goal of using a function is to break down the functionality of a script into a smaller section that can be called upon to perform individual tasks. Functions are particularly useful if you have a recurring code block to avoid having the same large code block in multiple spots throughout the script. [For more information on function usage and syntax](https://www.tutorialspoint.com/unix/unix-shell-functions.htm) As per the requirements, the usage statement is going to give instructions on what the valid flags are and what they do.
```
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
```
Verifying that the script is NOT being executed with root privileges: (remember, the script must be executed with the -s option if the user needs to use the script with root privileges)
```
if [[ "${UID}" -eq 0 ]]
then
  echo 'You cannot execute this script as root by default. Confirm you want to execute this script as root and use
  the -s option to do so.' >&2
  usage
fi
```
Parsing the options passed to the command:
```
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
```
The code block above utilizes a while loop and the [getopts](https://linuxconfig.org/how-to-use-getopts-to-parse-a-script-options) built-in to parse the script options. The reason the 'f' has a colon after it is because if the -f flag is specified, there has to be a file name specified after it that the user wishes to use in place of the default server list file. The other flag options lack the colon as they don't require any additional arguments. When a user enters any of the valid flag options it will call the code after the parenthesis, for example, if the -n flag is specified, then the ${TEST_RUN} variable will be set to true.
[Shifting](https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_09_07.html) over the options and leaving the remaining arguments: (in this scripts case, the remaining argument would be the command that is supposed to execute on the servers in ${SERVER_LIST})
```
shift "$(( OPTIND -1 ))"
```
If the user doesn't supply atleast one argument (the command that is supposed to execute), display the usage function created earlier:
```
if [[ "${#}" -lt 1 ]]
then
  usage
fi
```
Anything that remains on the command line after being shifted is treated as a single command:
```
COMMAND="${@}"
```
Verifying that the SERVER_LIST file exists:
```
if [[ ! -e "${SERVER_LIST}" ]]
then
  echo "Cannot open server list file ${SERVER_LIST}." >&2
  exit 1
fi
```
Initializing a variable that represents a successful exit status code, which is going to be used as the default:
```
S_EXIT_STATUS='0'
```
Looping through the SERVER_LIST file and parsing the various options:
```
for SERVER in $(cat ${SERVER_LIST})
do
  if [[ "${VERBOSE}" = 'true' ]]
  then
    echo "${SERVER}"
  fi
```
If the -v flag was set, the ${VERBOSE} option would be set to true, in which case the script is going to output the server that the command was executed on before any command output. Initializing a variable to represent the options on the ssh command:
```
  SSH_COMMAND="ssh ${SSH_OPTIONS} ${SERVER} ${SUDO} ${COMMAND}"
```
The ${SSH_OPTIONS} is set to '-o ConnectTimeout=2' to prevent the script from waiting more than 2 seconds on a machine that is down. The ${SERVER} is the server that the command is going to be executed on. ${SUDO} checks if the command should be executed with root privileges (the -s flag will override the default of non-root execution). Lastly, ${COMMAND} is the command that is to be executed as per the argument provided to the script.


If the -n option was specified, print out the command that would have executed, without actually doing anything. If the -n option was not specified, execute the command set the S_EXIT_STATUS variable created earlier to the exit status of the command (the default is 0, however, if the script fails then the exit status will be changed accordingly):
```
if [[ "${TEST_RUN}" = 'true' ]]
then
  echo "TEST RUN: ${SSH_COMMAND}"
else
  ${SSH_COMMAND}
  S_EXIT_STATUS="${?}"
```
If the exit status is anything other than 0 (successful), inform the user:
```
if [[ "${S_EXIT_STATUS}" -ne 0 ]]
then
  EXIT_STATUS="${S_EXIT_STATUS}"
  echo "Command execution on ${SERVER} failed." >&2
fi
fi
done
```
The 'done' at the bottom ends the for loop created earlier. The script will exit with the exit status of the ssh command:
```
exit ${EXIT_STATUS}
```
For example,
```
[vagrant@admin01 vagrant]$ ./p -n ps
```
Output:
```
TEST RUN: ssh -o ConnectTimeout=2 server01  ps
TEST RUN: ssh -o ConnectTimeout=2 server02  ps
```
The command ran successfully, if you check the exit status of the script afterward:
```
echo $?
```
Output:
```
0
```
# Sample Output

# Default

Using the script with no flags example:
```
./execCmdMultipleServers.sh df
```
Output:
```
Filesystem               1K-blocks      Used Available Use% Mounted on
/dev/mapper/vg00-lv_root  35993120   1431176  32710552   5% /
devtmpfs                    239100         0    239100   0% /dev
tmpfs                       249984         0    249984   0% /dev/shm
tmpfs                       249984      4452    245532   2% /run
tmpfs                       249984         0    249984   0% /sys/fs/cgroup
/dev/sda1                   999320    126768    803740  14% /boot
vagrant                  929903092 458770192 471132900  50% /vagrant
tmpfs                        50000         0     50000   0% /run/user/1000
Filesystem               1K-blocks      Used Available Use% Mounted on
/dev/mapper/vg00-lv_root  35993120   1431176  32710552   5% /
devtmpfs                    239100         0    239100   0% /dev
tmpfs                       249984         0    249984   0% /dev/shm
tmpfs                       249984      4452    245532   2% /run
tmpfs                       249984         0    249984   0% /sys/fs/cgroup
/dev/sda1                   999320    126768    803740  14% /boot
vagrant                  929903092 458770192 471132900  50% /vagrant
tmpfs                        50000         0     50000   0% /run/user/1000
```
# -f flag
Using the script with the -flag:
```
./execCmdMultipleServers.sh -f /vagrant/new_servers ping -c 3 google.com
```
Output:
```
PING google.com (172.217.5.14) 56(84) bytes of data.
64 bytes from lga15s49-in-f14.1e100.net (172.217.5.14): icmp_seq=1 ttl=53 time=11.2 ms
64 bytes from lga15s49-in-f14.1e100.net (172.217.5.14): icmp_seq=2 ttl=53 time=11.8 ms
64 bytes from lga15s49-in-f14.1e100.net (172.217.5.14): icmp_seq=3 ttl=53 time=9.57 ms

--- google.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2536ms
rtt min/avg/max/mdev = 9.575/10.887/11.844/0.963 ms
PING google.com (216.58.192.142) 56(84) bytes of data.
64 bytes from ord36s01-in-f142.1e100.net (216.58.192.142): icmp_seq=1 ttl=53 time=9.59 ms
64 bytes from ord36s01-in-f142.1e100.net (216.58.192.142): icmp_seq=2 ttl=53 time=10.9 ms
64 bytes from ord36s01-in-f142.1e100.net (216.58.192.142): icmp_seq=3 ttl=53 time=11.8 ms

--- google.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2510ms
rtt min/avg/max/mdev = 9.597/10.813/11.853/0.929 ms
```
# -n flag
Using the script with the -n flag:
```
./execCmdMultipleServers.sh -n
```
Output:
```
TEST RUN: ssh -o ConnectTimeout=2 server01  ping -c 2 github.com
TEST RUN: ssh -o ConnectTimeout=2 server02  ping -c 2 github.com
```
# -s flag
An example of when the -s flag would be useful, trying to run 'ifconfig' with the script without any flags:
```
./execCmdMultipleServers.sh ifconfig
```
Output:
```
Command execution on server01 failed.
Command execution on server02 failed.
```
Now running that same command with the -s flag:
```
./execCmdMultipleServers.sh -s ifconfig
```
Output (output trimmed for size):
```
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.2.15  netmask 255.255.255.0  broadcast 10.0.2.255
        inet6 fe80::a00:27ff:fee8:7dcf  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:e8:7d:cf  txqueuelen 1000  (Ethernet)
        RX packets 741  bytes 85092 (83.0 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 587  bytes 89505 (87.4 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.2.15  netmask 255.255.255.0  broadcast 10.0.2.255
        inet6 fe80::a00:27ff:fee8:7dcf  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:e8:7d:cf  txqueuelen 1000  (Ethernet)
        RX packets 722  bytes 83696 (81.7 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 589  bytes 91995 (89.8 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```
# -v flag
Using the script with the -v flag (note: using the -s flag also to be able to use ifconfig without an error):
```
./execCmdMultipleServers.sh -sv ifconfig
```
Output (output trimmed for size):
```
server01
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.2.15  netmask 255.255.255.0  broadcast 10.0.2.255
        inet6 fe80::a00:27ff:fee8:7dcf  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:e8:7d:cf  txqueuelen 1000  (Ethernet)
        RX packets 741  bytes 85092 (83.0 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 587  bytes 89505 (87.4 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

server02
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.2.15  netmask 255.255.255.0  broadcast 10.0.2.255
        inet6 fe80::a00:27ff:fee8:7dcf  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:e8:7d:cf  txqueuelen 1000  (Ethernet)
        RX packets 722  bytes 83696 (81.7 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 589  bytes 91995 (89.8 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```
Compare the output of this to the output from just using the -s flag above. When combined with the -v option, it is much easier to determine which servers configuration you are looking at. With just 2 servers it isn't that big of a problem, but imagine if you were administrating 100's of servers; trying to pinpoint which config belongs to the 55th server without the -v flag would be a nightmare!

# Invalid Command
Using the script with an invalid command:
```
./execCmdMultipleServers.sh ipconfig
```
Output:
```
Command execution on server01 failed.
Command execution on server02 failed.
```

# Invalid Flag
Using the script with an invalid flag should prompt the usage function to be displayed:
```
./execCmdMultipleServers.sh -b ipconfig
```
Output:
```
./execCmdMultipleServers.sh: illegal option -- b
Usage: ./execCmdMultipleServers.sh [-nsv] [-f FILE] COMMAND
Executes COMMAND as a single command on every server.
 -f FILE   Use FILE for the list of servers. Default /vagrant/servers.
 -n        Test run mode. Display the COMMAND that would have been executed without actually executing
  them.
 -s        Execute the COMMAND with root privileges on the remote server.
 -v        Verbose mode. Displays the server name before executing COMMAND.
 ```
# Failure Exit Code
After using the script improperly:
```
./execCmdMultipleServers.sh ipconfig
```
Printing the exit status:
```
echo $?
```
Output:
```
1
```
# Success Exit Code
After the script runs without any issues:
```
./execCmdMultipleServers.sh hostname
```
Output:
```
server01
server02
```
Printing the exit status:
```
echo $?
```
Output:
```
0
```
