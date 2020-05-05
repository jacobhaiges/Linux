# Setup
Once Vagrant is installed, you will need to navigate to the command line on your machine and run the following command:

```
vagrant box add jasonc/centos7
```

This command adds a Vagrant box, which is an operating system image. Once a box is added, it can be cloned infininitely.
Note: Other boxes can be installed [here:](https://app.vagrantup.com/boxes/search)

You will need to create a folder to store your work.
```
mkdir LinuxLab
```

Make sure you move into that directory by using
```
cd LinuxLab
```

Next, create a folder to store your Vagrant project.
```
mkdir lab01
```

To initialize a Vagrant project, use:
```
cd mkdir lab01
vagrant init jasonc/centos7
```

# Creating your first virtual machine

To bring up the Vagrant virtual machine, use
```
vagrant up
```

To verify that the VM is running, open up VirtualBox and check if there is any VM's running.
In addition, you can use
```
vargrant status
```

# Connecting to the virtual machine

To connect to the virtual machine, use the vagrant command
```
vagrant ssh
```
After running 'vagrant ssh', the prompt should switch to a prompt like this: ![](images/vagrantcmdLine.png)

Let's make some config changes, use
```
exit
```
to exit and return to your machines command prompt.

# Stopping the virtual machine

The
```
vagrant halt
```
command shuts down the virtual machine.

# Changing configuration details

Locate the file where you created your vagrant project, in my case:
```
C:\users\jacob\documents\LinuxLab\lab01
```
Vagrant automatically creates a Vagrantfile that controls the settings of your virtual machine, these
settings can be changed with a text editor (I like the [Atom](https://atom.io/) text editor but it doesn't matter).

You will see this line near the top
```
Vagrant.configure("2") do |config|
```
Somewhere after that line and the end at the bottom, add the following line
```
config.vm.hostname = "centos7box"
```
We're going to change some more configuration details, under the hostname line, add the following
```
config.vm.network "private_network", ip: "10.9.8.7"
```
Remember to save the changes to the file.

To reload the configuration changes, you can run
```
vagrant reload
```
To test the connectivity of the virtual machine, use the following command
```
ping 10.9.8.7
```
When you create the virtual machine with Vagrant, it automatically mounts a shared folder.
You can access the files that are on your local machine from inside of the virtual machine. The shared directory location is
```
/vagrant ---> C:\~project path that you initialized the Vagrant box in~
```
If you list the contents of of /vagrant, you can see the Vagrantfile that you edited outside of the virtual machine. To see the shared files in action use the following
```
cat /vagrant/Vagrantfile
```

# Destroying the virtual machine

Once you are done with the virtual machine or if you want to start over, use the following command
```
vagrant destroy
```
Answer "y" on the prompt to confirm deletion.

# Bonus

If you want to mess around with the Vagrantfile and create 2 virtual machines, this section will show you how to do that.

First, navigate 1 directory up using
```
cd ..
```
And create a new folder for the Vagrant project
```
mkdir twoVMtest
cd twoVMtest
```
Initialize the Vagrant project
```
vagrant init jasonc/centos7
```
Edit the Vagrantfile and add the following lines
```
Vagrant.configure("2") do |config|
  config.vm.box = "jasonc/centos7"
  config.vm.define "box1" do |box1|
    test1.vm.hostname = "box1"
    test1.vm.network "private_network", ip: "10.9.8.5"
  end
  config.vm.define "box2" do |box2|
    test2.vm.hostname = "box2"
    test2.vm.network "private_network", ip: "10.9.8.6"
  end
end
```
Start the VM's with
```
vagrant up
```
Let's test the connectivity by logging into box2 and pinging box1 to ensure they can communicate.
```
vagrant ssh box1
ping 10.9.8.5
```


# Troubleshooting

Upon changing the IP address configuration details I got an error the first time
```
Failed to open/create the internal network 'HostInterfaceNetworking-VirtualBox Host-Only Ethernet Adapter' (VERR_INTNET_FLT_IF_NOT_FOUND).
```
IF you get this error, try navigating to Control Panel > Network and Internet > Network Connections,
and disabling and reenabling the VirtualBox Host-Only Ethernet Adapter. ![](images/networkTroubleshooting.png)
