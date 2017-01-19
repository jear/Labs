#!/bin/bash

# Checking tool deps
which docker-compose 
if [ $? -ne 0 ]; then
	if [ !  -f ./docker-compose ]; then
		curl -L https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m) > ./docker-compose
		chmod 755 docker-compose
	fi
fi

for tool in sed docker
do
	echo "Checking $tool"
	which $tool || exit 1
done

# If a FW is up with firewalld issue:
# firewall-cmd --add-port=80/tcp --permanent
# firewall-cmd --add-port=5000/tcp --permanent

echo "Enter the public fqdn of your registry (IP will not work)"
read FQDN
sed -i -r -e "s/PUBFQDN=.*/PUBFQDN=$FQDN/" docker-compose.yml
./docker-compose up -d --build
sed -i -r -e "s/PUBFQDN=$FQDN/PUBFQDN=/" docker-compose.yml
