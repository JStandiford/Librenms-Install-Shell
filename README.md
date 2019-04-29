## Automated installation of LibreNMS
LibreNMS is an open source network device management software.

## Install Steps：

### Step 1: Create VM and use settings from librenms_vmsettings
   > ftp://ftp.k12tech.net/QNSTECHS/Jason%20Standiford/NetworkMonitor/LibreNMS_Files/


### Step 2: Download and Install CentOS to the new VM
   > ftp://ftp.k12tech.net/QNSTECHS/Jason%20Standiford/NetworkMonitor/CentOS-ks.iso
   
   
### Step 3: Verify static IP on new VM per librenms_vmsettings using one of the following methods

    vi /etc/sysconfig/network-scripts/ifcfg-eth0
    
    nmtui << change hostname if non qnsk12.edu domain


### Step 4: Update System
    yum install nano
    yum install git
    yum -y update
    


### Step 5: Clone Git 
    git clone https://github.com/JStandiford/Librenms-Install-Shell.git


### Step 6:
Run install script depending on the system, and root is recommended for installation
  
  
#### CentOS 7 or above
  
    sh Librenms-Install-Shell/Centos7_install.sh
  
#### Ubuntu 16.04 or above  

    sh Librenms-Install-Shell/ubuntu_install.sh (needs updated)
    
    
Delete the server section from /etc/nginx/nginx.conf to disable the default site


### Step 7: Set Timezone in php.ini

      nano /etc/php.ini
   
         date.timezone = America/Chicago


### Step 7:
    nano /etc/snmp/snmpd.conf
Set your community string by replacing RANDOMSTRINGGOESHERE
Set location and contact info
   
    curl -o /usr/bin/distro https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/distro
   
    chmod +x /usr/bin/distro
   
    systemctl enable snmpd
   
    systemctl restart snmpd
      
      
### Step 8:
Open the browser and connect to：http://YourLibreNMSIP/install.php  and make related settings based on the content (such as DB Password、DB Name, gui login info,).  Correct any errors based the info given.  

Create the config file and paste the contents provided to /opt/librenms/config.php

    nano /opt/librenms/config.php

    chown librenms:librenms /opt/librenms/config.php
    
Return to gui setup and 'Finish Install'


### Step 9:
Open browser and go to: http://librenms-centos.qnsk12.edu

Login and validate the install



### Step 10:
Add your first device by adding the localhost (server LibreNMS is running on) 


### Step 11:
Edit LibreNMS config.php file with custom config.php file


### Step 12:
    ./validate.php
    ./daily.sh
    ./snmp-scan.py


### Step 13:
Setup Alert Rules, Alert Templates, and Alert Transports per screenshots and txt docs


### Step : 
Setup Oxidized


### Switch SNMP 
Modifiy the SNMP settings on your switches

    #CISCO
    conf t
    snmp-server community CommunityString
    snmp-server enable trap 
    snmp-server host IP version 2c CommunityString
    end
    write memory 


    #Aruba
    configure t
    snmp-server community CommunityString
    snmp-server enable trap 
    snmp-server host IP version 2c CommunityString
    exit
    write memory
    
    
### Setup Telnet/SSH URL Handler
Follwing instructions via this link:  https://ipfabric.atlassian.net/wiki/spaces/NK/pages/91619331/Set+Up+Telnet+SSH+URL+Handler+on+MS+Windows+7+and+later




### Installation Videos provided by BensonRUEI
   
    CentOS 7 install LibreNMS
[![](http://img.youtube.com/vi/UxsgXax2wBE/0.jpg)](http://www.youtube.com/watch?v=UxsgXax2wBE "")
