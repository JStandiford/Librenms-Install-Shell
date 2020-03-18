## Automated installation of LibreNMS
LibreNMS is an open source network device management software.

## Install Steps：

### Step 1: Import CentOS VM
   > (ftp://ftp.k12tech.net/QNSTECHS/Jason%20Standiford/NetworkMonitor/LibreNMS_Files)

      
### Step 2: Verify static IP on new VM per librenms_vmsettings using one of the following methods

    vi /etc/sysconfig/network-scripts/ifcfg-eth0
    
    nmtui << change hostname if non qnsk12.edu domain
    
    vi /etc/resolv.conf << change search name if non qnsk12.edu domain


### Step 3: Update System
    yum install nano
    yum install git
    yum clean all
    yum makecache
    yum check-update
    yum -y update
    

### Step 4: Clone Git 
    git clone https://github.com/JStandiford/Librenms-Install-Shell.git


### Step 5:
Run install script; root is recommended for installation
  
    sh Librenms-Install-Shell/Centos7_install.sh
    
    
### Step 6: Post Script Tasks
- Delete the server section from /etc/nginx/nginx.conf to disable the default site

- Fix server name if non qnsk12.edu domain

      nano /etc/nginx/conf.d/librenms.conf

- Set Timezone in php.ini - find date.timezone and set to America/Chicago  (make sure to uncomment the line by removing the ;)

      nano /etc/php.ini

- Setup SNMP on the server

      nano /etc/snmp/snmpd.conf
     
         - Set your community string by replacing RANDOMSTRINGGOESHERE
         - Set location and contact info
   
      - curl -o /usr/bin/distro https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/distro
   
      - chmod +x /usr/bin/distro
   
      - systemctl enable snmpd
   
      - systemctl restart snmpd

      - chown -R librenms:librenms /opt/librenms        
      
      
### Step 7:
Open the browser and connect to：http://YourLibreNMSIP/install.php  and make related settings based on the content (such as DB Password、DB Name, gui login info,).  Correct any errors based on the info given.  

Create the config file and paste the contents provided to /opt/librenms/config.php

    nano /opt/librenms/config.php

    chown librenms:librenms /opt/librenms/config.php
    
Return to gui setup and 'Finish Install'


### Step 8:
Open browser and go to: qnsnetmon\

Login and validate the install


### Step 9:
Add your first device by adding the localhost (server LibreNMS is running on) 


### Step 10:
Edit LibreNMS config.php file with custom config.php file


### Step 11:
    ./validate.php
    ./daily.sh
    ./snmp-scan.py


### Step 12:
Setup Alert Rules, Alert Templates, and Alert Transports per screenshots and txt docs


### Step 13: Setup Oxidized

Install Ruby 2.3 build dependencies

    yum install curl gcc-c++ patch readline readline-devel zlib zlib-devel
    yum install libyaml-devel libffi-devel openssl-devel make cmake
    yum install bzip2 autoconf automake libtool bison iconv-devel libssh2-devel libicu-devel

Install RVM

    curl -L get.rvm.io | bash -s stable

Setup RVM environment and compile and install Ruby 2.3 and set it as default

    source /etc/profile.d/rvm.sh
    rvm install 2.3
    rvm use --default 2.3
    
Install Oxidized

    gem install oxidized 
    gem install oxidized-script
    gem install oxidized-web
    
Run oxidized twice to generate config files

    oxidized
    oxidized 

Edit the config file with contents of custom config file

    nano /root/.config/oxidized/config
    
Copy Oxidized service

Find the service:

    sudo find / -name "oxidized.service"
Notate the path, and move to systemd based on the location discovered from “find”; the oxidized service file contains notes on the correct path to copy per flavor of linux:

    cp /usr/local/rvm/gems/ruby-2.3.8/gems/oxidized-0.26.3/extra/oxidized.service /usr/lib/systemd/system/

Change user from “oxidized” to “root” and edit the ExecStart within the oxidized.service file:

    nano /usr/lib/systemd/system/oxidized.service
    
ExecStart=/usr/local/rvm/gems/ruby-2.3.8/wrappers/oxidized     
    
Oxidized will pull information via the LibreNMS API; the API can be generated through the LIbreNMS web interface at:
Settings -> API -> API Settings

After generating the token, test the token with the following command:

    curl -H ‘X-Auth-Token: 1234567890’ http://127.0.0.1/api/v0/oxidized
    
Start the service, add firewall exception for correct zone

    sudo systemctl daemon-reload
    sudo systemctl enable oxidized.service
    sudo systemctl start oxidized
    sudo systemctl status oxidized
    sudo firewall-cmd --zone=public --permanent --add-port=8888/tcp
    firewall-cmd --permanent --zone=trusted --add-port=8843/tcp
    firewall-cmd --reload
    

### Switch SNMP 
Modifiy the SNMP settings on your switches

    #Cisco
    conf t
    snmp-server community CommunityString
    snmp-server enable trap 
    snmp-server host <IP> version 2c <CommunityString>
    end
    write memory 

    
    #Aruba
    config
    snmp-server community CommunityString 
    snmp-server host <IP> community <communityname>
    exit
    write memory
    
    
### Setup Telnet/SSH URL Handler
Follwing instructions via this link:  https://ipfabric.atlassian.net/wiki/spaces/NK/pages/91619331/Set+Up+Telnet+SSH+URL+Handler+on+MS+Windows+7+and+later


### Installation Videos provided by BensonRUEI
   
    CentOS 7 install LibreNMS
[![](http://img.youtube.com/vi/UxsgXax2wBE/0.jpg)](http://www.youtube.com/watch?v=UxsgXax2wBE "")

