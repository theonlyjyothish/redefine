#
# Cookbook Name:: openvpn
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
execute "system update" do
  command "apt-get update"
end

execute "install openvpn packages" do
command "apt-get install -y openvpn easy-rsa" 
end

execute "copy example configuration" do
command "gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz > /etc/openvpn/server.conf"
end

template "/etc/openvpn/server.conf" do
source "server.conf.erb"
end

execute "enable packet forwarding" do
command "echo 1 > /proc/sys/net/ipv4/ip_forward"
end

execute "enable packet forwarding permenately" do
command "echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf"
end

execute "copy easy-rsa generation scripts" do
command "cp -r /usr/share/easy-rsa/ /etc/openvpn"
end

directory '/etc/openvpn/easy-rsa/keys' do
owner 'root'
group 'root'
mode '0700'
action :create
end

template "/etc/openvpn/easy-rsa/vars" do
source "vars.erb"
end

#execute "generate the Diffie-Hellman parameters" do
#command "openssl dhparam -out /etc/openvpn/dh2048.pem 2048"
#end

bash 'run as a service' do
  cwd '/etc/openvpn/easy-rsa'  
  code <<-EOF
  sudo . ./vars
  sudo ./clean-all
  EOF
end

template "/etc/openvpn/easy-rsa/keys/server.crt" do
source "server.crt.erb"
end

template "/etc/openvpn/easy-rsa/keys/server.key" do
source "server.key.erb"
end

template "/etc/openvpn/easy-rsa/keys/ca.crt" do
source "ca.crt.erb"
end

execute "copy certificates" do
command "cp /etc/openvpn/easy-rsa/keys/server.crt /etc/openvpn"
end

execute "copy certificates" do
command "cp /etc/openvpn/easy-rsa/keys/server.key /etc/openvpn"
end

execute "copy certificates" do
command "cp /etc/openvpn/easy-rsa/keys/ca.crt /etc/openvpn"
end

execute "start the openvpn service" do
command "service openvpn start"
end
