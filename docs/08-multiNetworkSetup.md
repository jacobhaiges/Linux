# Setup
To configure this multiple system network, open up the Vagrantfile and change some configuration:
```
config.vm.box = "jasonc/centos7"

config.vm.define "admin01" do |admin01|
  admin01.vm.hostname = "admin01"
  admin01.vm.network "private_network", ip: "10.9.8.10"
end

config.vm.define "server01" do | server01|
  server01.vm.hostname = "server01"
  server01.vm.network "private_network", ip: "10.9.8.11"
end

config.vm.define "server02" do |server02|
  server02.vm.hostname = "server02"
  server02.vm.network "private_network", ip: "10.9.8.12"
end
```
The config above defines 3 virtual machines which will all start up upon running
```
vagrant up
```
To connect to one of the virtual machines you have to specify which VM you want to connect to, ex:
```
vagrant ssh admin01
```
```
vagrant ssh server01
```
```
vagrant ssh server02
```
I'm going to connect to admin01. To test the connectivity to the other virtual machines, use the ping command:
```
ping 10.9.8.11
```
Sample output:
```
64 bytes from 10.9.8.11: icmp_seq=1 ttl=64 time=0.612 ms
64 bytes from 10.9.8.11: icmp_seq=2 ttl=64 time=0.341 ms
64 bytes from 10.9.8.11: icmp_seq=3 ttl=64 time=0.441 ms
```
Instead of having to refer to server01 by its IP address, the [hosts file](https://linuxize.com/post/how-to-edit-your-hosts-file/) can be changed to include server01 and server02. To edit the /etc/hosts file the [tee](https://www.geeksforgeeks.org/tee-command-linux-example/) command can be used (note: the reason I'm using tee here is to prevent getting a permission denied error):
```
echo 10.9.8.11 server01 | sudo tee -a /etc/hosts
```
```
echo 10.9.8.12 server02 | sudo tee -a /etc/hosts
```
Tee reads the standard input and redirects it to a file, in this case, the /etc/hosts file. Normally echo would send the output to standard out, but the output is being piped to the tee command. The tee command is going to read the standard input from the echo command, and write it to the /etc/hosts file. Note: all the hosts file needs is an IP address and the hostname.


After adding the servers to the hosts file, let's try a ping with the hostname:
```
ping server01
```
Sample output:
```
64 bytes from server01 (10.9.8.11): icmp_seq=1 ttl=64 time=0.342 ms
64 bytes from server01 (10.9.8.11): icmp_seq=2 ttl=64 time=0.273 ms
64 bytes from server01 (10.9.8.11): icmp_seq=3 ttl=64 time=0.284 ms
```
Notice that now it says 64 bytes from server01 with the IP address in parenthesis.

# Configuring SSH Authentication
In this lab environment the goal is to be able to connect to the servers from the admin machine. To do this without needing a password, an ssh key needs to be created. To do this, use the [ssh-keygen](https://www.ssh.com/ssh/keygen/):
```
ssh-keygen
```
I'm going to accept all the defaults after entering the command.
Sample output:
```
Generating public/private rsa key pair.
Enter file in which to save the key (/home/vagrant/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/vagrant/.ssh/id_rsa.
Your public key has been saved in /home/vagrant/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:4IlHyBemPAPkQp0HsZcNa1UdlUzqosCPFG3DpPYNJT4 vagrant@admin01
The key's randomart image is:
+---[RSA 2048]----+
| o+o+.o+.o..=o.  |
|.. *.=%.o  ..o   |
|. ..OO+E   .     |
| .  =B+o= .      |
|    .++.So .     |
|    ..+ . .      |
|     . o         |
|                 |
|                 |
+----[SHA256]-----+
```
Next to copy the public key use:
```
ssh-copy-id server01
```
* Note: Make sure you say 'yes' when prompted if you want to continue connecting, and the password is 'vagrant'.


Sample output:
```
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/vagrant/.ssh/id_rsa.pub"
The authenticity of host 'server01 (10.9.8.11)' can't be established.
ECDSA key fingerprint is SHA256:Fi4FisVgFyEkos9NgKz0q+zzZwe3+xhCHWGrXL+jZck.
ECDSA key fingerprint is MD5:b6:04:55:d7:db:3c:a8:a1:b6:f6:15:1f:be:7e:48:41.
Are you sure you want to continue connecting (yes/no)? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
vagrant@server01's password: vagrant

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'server01'"
and check to make sure that only the key(s) you wanted were added.
```
To verify that it works, try to connect to server01 with ssh:
```
ssh server01
```
And the prompt changes accordingly:
```
[vagrant@server01 ~]$  
```
To exit back to admin01:
```
exit
```


To run a command on server01 from admin01 without connecting to it:
```
ssh server01 hostname
```
Sample output:
```
server01
```


To be able to ssh to server02 from admin01 you have to use ssh-copy-id again:
```
ssh-copy-id server02
```


With both of the ssh keys configured, here's a simple command to run on both servers:
```
for N in 1 2
do
ssh server0${N} hostname
done
```
Sample output:
```
server01
server02
```


To make a file with the names of the servers
Note: the '>>' will append to a file
```
echo 'server01' > servers
echo 'server02' >> servers
```
Reading that file:
```
cat servers
```
Sample output:
```
server01
server02
```
With that new servers file you can use it in scripts like so:
```
for SERVER in $(cat servers)
do
ssh ${SERVER} hostname
ssh ${SERVER} uptime
done
```
Sample output:
```
server01
 21:01:28 up 45 min,  0 users,  load average: 0.00, 0.01, 0.05
server02
 21:01:28 up 43 min,  0 users,  load average: 0.00, 0.01, 0.05
```


To execute multiple commands with one ssh statement you can contain the commands you want to execute in quotation marks:
```
ssh server01 'ps -ef | head -3'
```
Sample output:
```
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  0 20:16 ?        00:00:01 /usr/lib/systemd/systemd --switched-root --system --deserialize 21
root         2     0  0 20:16 ?        00:00:00 [kthreadd]
```



* Note on exit statuses: SSH will exit with the exit status of the remote command, or with an exit status of 255 if an error with SSH occurred. To demonstrate this:
```
ssh server55
```
Sample output:
```
255
```
The return status of a remote command that is valid:
```
ssh server01 hostname
```
Sample output:
```
0
```

# Simple script to ping a list of servers and report their status.
```
#!/usr/bin/env bash

# This script pings a list of servers and reports on their status.

SERVER_FILE='/vagrant/servers'
# Server file contains:
# server01
# server02

if [[ ! -e "${SERVER_FILE}" ]]
then
  echo "Cannot open ${SERVER_FILE}." >&2
  exit 1
fi

for SERVER in $(cat ${SERVER_FILE})
do
  echo "Pinging ${SERVER}"
  ping -c 3 ${SERVER} &> /dev/null
  if [[ "${?}" -eq 0 ]]
  then
    echo "${SERVER} up."
  else
    echo "${SERVER} down."
  fi
done
```
This script is using a for loop to read in both of the server names listed in the server file and pings each of them with '-c 3' which is 3 icmp packets. If the exit status of the ping (success) is a 0, then that server is reported as being up. Otherwise, the server is reported as being down.

Sample output when both servers are up and working:
```
Pinging server01
server01 up.
Pinging server02
server02 up.
```
Sample output when server02 is down but server01 is up:
```
Pinging server01
server01 up.
Pinging server02
server02 down.
```
