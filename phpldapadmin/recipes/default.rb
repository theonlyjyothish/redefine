#
# Cookbook Name:: phpldapadmin
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
execute "installapache2" do
  command "apt-get install -y apache2"
end

execute "installphpldapadmin" do
command "apt-get install -y phpldapadmin" 
end

execute "installapache2 utils" do
command "apt-get install -y apache2-utils"
end

execute "install expect" do
command "apt-get install -y expect"
end

bash 'passforhtpass' do
	code <<-EOF
sudo /usr/bin/expect -c 'spawn htpasswd -c /etc/apache2/htpasswd ldap-admin
expect "password:"
        send "test123\r"
expect "password:"
	send "test123\r"
expect eof'
        EOF
    end

directory '/etc/apache2/ssl' do
owner 'root'
group 'root'
mode '0755'
action :create
end

bash "installssl certs" do
cwd='/etc/apache2/ssl'
	code <<-EOF
openssl req -nodes -newkey rsa:2048 -keyout apache.key -out apache.crt -subj "/C=IN/ST=Kerala/L=Kochi/O=letmesolve/OU=IT Department/CN=letmesolve.com"
	EOF
end

execute "enable apache2 ssl" do
command "a2enmod ssl"
end

template "/etc/phpldapadmin/config.php" do
source "config.php.erb"
end

template "/etc/phpldapadmin/apache.conf" do
source "apache.conf.erb"
end

template "/etc/apache2/sites-enabled/000-default.conf" do
source "000-default.conf.erb"
end

execute "enable000-default.conf" do
command "a2ensite default-ssl.conf"
end

template "/etc/apache2/sites-enabled/default-ssl.conf" do
source "defaultssl.conf.erb"
end

template "/tmp/serverip.sh" do
source "serverip.erb"
end

bash 'run as a service' do
  cwd '/tmp'  
  code <<-EOF
  sudo chmod +x serverip.sh
  sudo sh serverip.sh
  EOF
end

bash 'fixing bug' do
  cwd '/usr/share/phpldapadmin/lib'
  code <<-EOF
  sed -i 's/password_hash/password_hash_custom/g' TemplateRender.php
	EOF
end

execute "restartapache2" do
command "service apache2 restart"
end

execute "installldap-utils" do
  command "apt-get install -y ldap-utils"
end
