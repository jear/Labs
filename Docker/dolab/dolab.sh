#!/bin/bash

##############################
# Create Digital Ocean droplet
##############################

function usage {

echo "Usage: $prog nb_instance flavor key [image]"
echo ""
echo "nb_instance	Number of instances required"
echo "flavor 		Instances flavor"
echo "key	        userkey name"
echo "image 		Instances image default: 14.04.5 x64"
echo ""
echo "Flavors:"
doctl compute size list
echo ""
echo "Images:"
doctl compute image list
exit 1
}

arg1=$(echo "$1" | tr [:upper:] [:lower:])
prog=$(basename $0)

echo "$1" | grep -Pq "\d+"
if [ "$?" != 0 ]
then
	usage
fi

if [ -z "$2" ]
then
	usage
fi

if [ -z "$3" ]
then
	usage
fi
KEYNAME=$3

if [ -z "$4" ]
then
	image="Docker 17.03.0-ce on 16.04"
else
	image=$4
fi

# Checking tool deps
for tool in ssh doctl jq
do
	echo "Checking $tool"
	which $tool || exit 1
done

# Following lines are not needed. Keys are pushed by DO. The key must be known by DO.
# Pushing keys to labhosts
#echo "Enter ssh pwd:"
#read -s sshpwd

# Create the required instances
for i in $(seq $arg1)
do
	doctl compute  droplet create docker-$3-$i --image $(doctl compute image list -o json | jq ".[] | select(.name==\"$image\") | .id") --size "$2" --region ams2 --ssh-keys 1997572
done

# Wait instance to be ready
for i in $(seq $arg1)
do
	instanceok="false"
	while [ "$instanceok" != "true" ]
	do
		doctl compute  droplet list | grep "docker-$3-$i" | grep "active"
		if [ "$?" != 0 ]
		then
			sleep 10s
		else
			instanceok="true"
		fi
	done
done

# Wait instances to be completely ready
sleep 20s



doctl compute droplet list | grep docker-$KEYNAME
for i in $(doctl compute droplet list | grep docker-$KEYNAME |  awk '{ print $3 }'); do cat $KEYNAME.pub | ssh -o StrictHostKeyChecking=no root@$i "cat >> .ssh/authorized_keys"; done
