#!/bin/bash

PASSWORD=`tr -dc a-z0-9_ < /dev/urandom | head -c 10`

cat << EOF | /usr/bin/expect
spawn /usr/bin/htpasswd -c /var/.htpasswd testuser
expect "password:"
send "$PASSWORD\r"
expect "password:"
send "$PASSWORD\r"
EOF

echo -e "\nPassword set to: $PASSWORD\n"
