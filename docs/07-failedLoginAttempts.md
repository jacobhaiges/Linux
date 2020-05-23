# Shell Script Goal
This shell script displays the number of failed login attempts by IP address and location.

# Shell Script Requirements
* Requires that a file is provided as an argument. If a file is not provided or cannot be read, then the script will display an error and message and exit with a status code of 1.
* Counts the number of failed login attempts by IP address. If there any any IP addresses with more than 10 failed attempts, then the number of attempts made, the IP address from which those attempts orignated from, and the location of the IP address will be displayed.
* Produces output in [CSV](https://www.howtogeek.com/348960/what-is-a-csv-file-and-how-do-i-open-it/) format with a header of "Count,IP,Location".

# Note
* I am going to use a sample log, [syslog-sample](syslog-sample). You can use this sample log or a different log if you would like.

# Writing the Shell Script
Starting the script:
```
touch failedLoginAttempts.sh
```
Pointing to the interpreter:
```
#!/usr/bin/env bash
```
The log file is going to be the first parameter supplied to the script:
```
LOG_FILE="${1}"
```
Verifying that a file was supplied as an argument:
```
if [[ ! -e "${LOG_FILE}" ]]
then
  echo "Cannot open log file: ${LOG_FILE}" >&2
  exit 1
fi
```
This code block is going to use an [if statement](https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_02.html) to check if whatever file specified in the LOG_FILE variable actually exists. If it does not, then it will print an error message and exit with a status of 1.
Next is to print the CSV headers we want:
```
echo 'Count,IP,Location'
```
Note: .csv files do not use a space when separating values as the comma serves as the delimiter.

Looping through the list of failed attempts and the corresponding IP addresses using grep, awk, sort, uniq, and a while loop.
```
grep Failed syslog-sample | awk '{print $(NF - 3)}' | sort | uniq -c | sort -nr | while read COUNT IP
do
```
[Grep](https://www.geeksforgeeks.org/grep-command-in-unixlinux/) is a filter that will search for patterns, and will display all of the characters that match the specified pattern. Grep is similar to [re](https://docs.python.org/3/library/re.html) in python, another way to use regular expressions.
Because we are looking for failed login attempts, the first filter I'm searching for is "Failed". \ Every subsequent command is going to narrow our search down and make it .csv format friendly. \ The next command I'm using is [awk](https://www.geeksforgeeks.org/awk-command-unixlinux-examples/), which is being used for pattern searching in this case. The usage of NF with awk represents the last field in a file, and the - 3 is used to say the 3rd field from the last. The reason I'm using the 3rd field from the last is because if you look at a sample line of output in the syslog-sample file:
```
Apr 15 19:59:11 spark sshd[16898]: Failed password for root from 183.3.202.111 port 17367 ssh2
```
The 3rd field from the last is an IP address, hence the (NF - 3). \ Next this information is going to be piped to the [sort](https://www.geeksforgeeks.org/sort-command-linuxunix-examples/) command to get the lines in order. \ The sorted information is piped to the [uniq](https://www.geeksforgeeks.org/uniq-command-in-linux-with-examples/) command, with the -c flag, which is going to give a count of how many times that particular line appeared. \ The next sort with the -nr flags is going to sort the numeric data in reverse order, giving the IP address with the most failures at the top followed by the next highest failure and so on. \ The while loop is going to take all the fields of the COUNT and the IP and for only the failed attempts with a count higher than 10, display the count, IP, and location:
```
if [[ "${COUNT}" -gt 10 ]]
then
  LOCATION=$(geoiplookup ${IP} | awk -F ', ' '{print $2}')
```
If the count value returned from the search string is higher than 10, the location is gathered using the [geoiplookup](https://linux.die.net/man/1/geoiplookup) command. Without the awk search, the output is a bit more messy, as shown here:
```
6749,182.100.67.59,GeoIP Country Edition: CN, China
3379,183.3.202.111,GeoIP Country Edition: CN, China
```
To clean up the output a little, the 2nd field delimited by a comma:
```
GeoIP Country Edition: CN
```
is going to be filtered out.
Finally, the command will print out the number of failed attempts, the IP address, the location, and exit with a status of 0.
```
echo "${COUNT},${IP},${LOCATION}"
fi
done
exit 0
```

# Sample Output
With a valid file (the sample file provided earlier):
```
./failedLoginAttempts.sh syslog-sample
```
Output:
```
Count,IP,Location
6749,182.100.67.59,China
3379,183.3.202.111,China
3085,218.25.208.92,China
142,41.223.57.47,Kenya
87,195.154.49.74,France
57,180.128.252.1,Thailand
27,208.109.54.40,United States
20,159.122.220.20,United States
```
Without a valid file:
```
./failedLoginAttempts.sh this-file-does-not-exist
```
Output:
```
Cannot open log file: this-file-does-not-exist
```
# Bonus
Now that there's a CSV list of the information we want, let's pipe that information into a file and use Powershell to read it.
```
./failedLoginAttempts.sh syslog-sample > failedLoginAttempts.csv
```
To check what available commands there is in Powershell for CSV's:
```
help *csv*
```
Output:
```
Name                              Category  Module                    Synopsis
----                              --------  ------                    --------
epcsv                             Alias                               Export-Csv
ipcsv                             Alias                               Import-Csv
ConvertFrom-Csv                   Cmdlet    Microsoft.PowerShell.U... Converts object properties in comma-separated ...
ConvertTo-Csv                     Cmdlet    Microsoft.PowerShell.U... Converts objects into a series of comma-separa...
Export-Csv                        Cmdlet    Microsoft.PowerShell.U... Converts objects into a series of comma-separa...
Import-Csv                        Cmdlet    Microsoft.PowerShell.U... Creates table-like custom objects from the ite...
Set-PcsvDeviceNetworkConfigura... Function  PcsvDevice                ...
Start-PcsvDevice                  Function  PcsvDevice                ...
Set-PcsvDeviceBootConfiguration   Function  PcsvDevice                ...
Restart-PcsvDevice                Function  PcsvDevice                ...
Set-PcsvDeviceUserPassword        Function  PcsvDevice                ...
Get-PcsvDevice                    Function  PcsvDevice                ...
Get-PcsvDeviceLog                 Function  PcsvDevice                ...
Clear-PcsvDeviceLog               Function  PcsvDevice                ...
Stop-PcsvDevice                   Function  PcsvDevice                ...
```
The cmdlet import-csv will do the trick. I have to specify the shared /vagrant directory that the failedLoginAttempts.csv file was created on. To check how to do that, I'm going to use
```
help import-csv
```
Output:
```
SYNTAX
    Import-Csv [[-Path]
```
Import-csv has a -path option, I'm going to specify my path, which is going to be different for everybody. Change the path to where ever the .csv file is stored.
```
import-csv -path C:\use\your\path\to\the\file\failedLoginAttempts.csv
```
Output:
```
Count IP             Location
----- --             --------
6749  182.100.67.59  China
3379  183.3.202.111  China
3085  218.25.208.92  China
142   41.223.57.47   Kenya
87    195.154.49.74  France
57    180.128.252.1  Thailand
27    208.109.54.40  United States
20    159.122.220.20 United States
```
