#Centos 7 install Librenms

#get ip
ip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`

# Install related kits
yum install -y epel-release
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
yum install -y composer cronie fping git ImageMagick jwhois mariadb mariadb-server mtr MySQL-python net-snmp net-snmp-utils nginx nmap php72w php72w-cli php72w-common php72w-curl php72w-fpm php72w-gd php72w-mbstring php72w-mysqlnd php72w-process php72w-snmp php72w-xml php72w-zip python-memcached python-ipaddress rrdtool

# New user
useradd librenms -d /opt/librenms -M -r
usermod -a -G librenms nginx

# Download LibreNMS
cd /opt
git clone https://github.com/librenms/librenms.git librenms

# Configure database
systemctl start mariadb
systemctl enable mariadb
mysql -u root <<EOF
	CREATE DATABASE librenms CHARACTER SET utf8 COLLATE utf8_unicode_ci;
	CREATE USER 'librenms'@'localhost' IDENTIFIED BY 'QNSis1monitordb';
	GRANT ALL PRIVILEGES ON librenms.* TO 'librenms'@'localhost';
	FLUSH PRIVILEGES;
	exit
EOF

> /etc/my.cnf.d/server.cnf
echo [server] >> /etc/my.cnf.d/server.cnf
echo [mysqld] >> /etc/my.cnf.d/server.cnf
echo 	innodb_file_per_table=1 >> /etc/my.cnf.d/server.cnf
echo 	sql-mode=\"\" >> /etc/my.cnf.d/server.cnf
echo 	lower_case_table_names=0 >> /etc/my.cnf.d/server.cnf
echo [embedded] >> /etc/my.cnf.d/server.cnf
echo [mysqld-5.5] >> /etc/my.cnf.d/server.cnf
echo [mariadb] >> /etc/my.cnf.d/server.cnf
echo [mariadb-5.5] >> /etc/my.cnf.d/server.cnf

systemctl restart mariadb

# Setting Web Server
echo date.timezone = \"America/Chicago\" >> /etc/php.ini

sed -e 's/user = apache/user = nginx/' -i /etc/php-fpm.d/www.conf
sed -e 's/\listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm\/php7.2-fpm.sock/' -i /etc/php-fpm.d/www.conf
echo listen.owner = nginx >> /etc/php-fpm.d/www.conf
echo listen.group = nginx >> /etc/php-fpm.d/www.conf
echo listen.mode = 0660 >> /etc/php-fpm.d/www.conf

systemctl enable php-fpm
systemctl restart php-fpm

# Setting NGINX
echo		server {	 >> /etc/nginx/conf.d/librenms.conf
echo		 listen      80\;	 >> /etc/nginx/conf.d/librenms.conf
echo		 server_name librenms-centos2.qnsk12.edu\; 	 >> /etc/nginx/conf.d/librenms.conf
echo		 root        \/opt\/librenms\/html\;	 >> /etc/nginx/conf.d/librenms.conf
echo		 index       index.php\;	 >> /etc/nginx/conf.d/librenms.conf
echo			 >> /etc/nginx/conf.d/librenms.conf
echo		 charset utf-8\;	 >> /etc/nginx/conf.d/librenms.conf
echo		 gzip on\;	 >> /etc/nginx/conf.d/librenms.conf
echo		 gzip_types text\/css application\/javascript text\/javascript application\/x-javascript image\/svg+xml text\/plain text\/xsd text\/xsl text\/xml image\/x-icon\;	 >> /etc/nginx/conf.d/librenms.conf
echo		 location \/ {	 >> /etc/nginx/conf.d/librenms.conf
echo		  try_files \$uri \$uri\/ \/index.php?\$query_string\;	 >> /etc/nginx/conf.d/librenms.conf
echo		 }	 >> /etc/nginx/conf.d/librenms.conf
echo		 location \/api\/v0 {	 >> /etc/nginx/conf.d/librenms.conf
echo		  try_files \$uri \$uri\/ \/api_v0.php?\$query_string\;	 >> /etc/nginx/conf.d/librenms.conf
echo		 }	 >> /etc/nginx/conf.d/librenms.conf
echo		 location \~ \\.php {	 >> /etc/nginx/conf.d/librenms.conf
echo		  include fastcgi.conf\;	 >> /etc/nginx/conf.d/librenms.conf
echo		  fastcgi_split_path_info \^\(.+\\.php\)\(\/.+\)\$\;	 >> /etc/nginx/conf.d/librenms.conf
echo		  fastcgi_pass unix:\/var\/run\/php-fpm\/php7.2-fpm.sock\;	 >> /etc/nginx/conf.d/librenms.conf
echo		 }	 >> /etc/nginx/conf.d/librenms.conf
echo		 location \~ \/\\.ht {	 >> /etc/nginx/conf.d/librenms.conf
echo		  deny all\;	 >> /etc/nginx/conf.d/librenms.conf
echo		 }	 >> /etc/nginx/conf.d/librenms.conf
echo		}	 >> /etc/nginx/conf.d/librenms.conf
systemctl enable nginx
systemctl restart nginx


# Setting SELinux
yum install -y policycoreutils-python
semanage fcontext -a -t httpd_sys_content_t '/opt/librenms/logs(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/opt/librenms/logs(/.*)?'
restorecon -RFvv /opt/librenms/logs/
semanage fcontext -a -t httpd_sys_content_t '/opt/librenms/rrd(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/opt/librenms/rrd(/.*)?'
restorecon -RFvv /opt/librenms/rrd/
semanage fcontext -a -t httpd_sys_content_t '/opt/librenms/storage(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/opt/librenms/storage(/.*)?'
restorecon -RFvv /opt/librenms/storage/
semanage fcontext -a -t httpd_sys_content_t '/opt/librenms/bootstrap/cache(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/opt/librenms/bootstrap/cache(/.*)?'
restorecon -RFvv /opt/librenms/bootstrap/cache/
setsebool -P httpd_can_sendmail=1
setsebool -P httpd_execmem 1

# Setting http_fping.tt
echo	module http_fping 1.0\;	 >> /opt/http_fping.tt
echo		 >> /opt/http_fping.tt
echo	require {	 >> /opt/http_fping.tt
echo	type httpd_t\;	 >> /opt/http_fping.tt
echo	class capability net_raw\;	 >> /opt/http_fping.tt
echo	class rawip_socket { getopt create setopt write read }\;	 >> /opt/http_fping.tt
echo	}	 >> /opt/http_fping.tt
echo		 >> /opt/http_fping.tt
echo	#============= httpd_t ==============	 >> /opt/http_fping.tt
echo	allow httpd_t self:capability net_raw\;	 >> /opt/http_fping.tt
echo	allow httpd_t self:rawip_socket { getopt create setopt write read }\;	 >> /opt/http_fping.tt

cd /opt
checkmodule -M -m -o http_fping.mod http_fping.tt
semodule_package -o http_fping.pp -m http_fping.mod
semodule -i http_fping.pp

# Configure Firewall
firewall-cmd --zone public --add-service http
firewall-cmd --permanent --zone public --add-service http
firewall-cmd --zone public --add-service https
firewall-cmd --permanent --zone public --add-service https

# Configure snmpd
cp /opt/librenms/snmpd.conf.example /etc/snmp/snmpd.conf

# Copy cron 
cp /opt/librenms/librenms.nonroot.cron /etc/cron.d/librenms

# Copy log file
cp /opt/librenms/misc/librenms.logrotate /etc/logrotate.d/librenms

# Configure LibreNMS
chown -R librenms:librenms /opt/librenms
setfacl -d -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/
setfacl -R -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/
chgrp apache /var/lib/php/session/
cd /opt/librenms
./scripts/composer_wrapper.php install --no-dev
chown -R librenms:librenms /opt/librenms

clear
echo " Installation Completed "
echo " Please open the URL: http://"yourlibrenmsIP"/install.php"
