## Automated installation of LibreNMS
LibreNMS is an open source network device management software.

## Install Steps：

### Step 1: Install CentOS or Ubuntu

### Step 2:
    git clone https://github.com/JStandiford/Librenms-Install-Shell.git
  
### Step 3:
Run install script depending on the system, and root is recommended for installation
  
  
#### CentOS 7 or above
  
    sh Librenms-Install-Shell/Centos7_install.sh
  
#### Ubuntu 16.04 or above  
    sh Librenms-Install-Shell/ubuntu_install.sh

### Step 4:
Open the browser and connect to：http://YourLibreNMSIP/install.php  and make related settings based on the content (such as DB Password、DB Name, gui login info,).  Correct any errors based the info given.  

Create the config file and paste the contents provided to /opt/librenms/config.php

    vim /opt/librenms/config.php

    chown librenms:librenms /opt/librenms/config.php
    
Return to gui setup and 'Finish Install'

### Step 5:
    
    
### Step 6:
Open browser and go to: http://librenms-centos.qnsk12.edu
Login and validate the install
    
### Step 7:
Add your first device by adding the localhost (server LibreNMS is running on) 
    
### Step 8:
Edit LibreNMS config.php file with custom config.php file
    
### Step 9: 
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


### Installation Videos provided by BensonRUEI
    Ubuntu 18.04 install LibreNMS
[![](http://img.youtube.com/vi/PDYOwL5pDG8/0.jpg)](http://www.youtube.com/watch?v=PDYOwL5pDG8 "")
    
    CentOS 7 install LibreNMS
[![](http://img.youtube.com/vi/UxsgXax2wBE/0.jpg)](http://www.youtube.com/watch?v=UxsgXax2wBE "")
