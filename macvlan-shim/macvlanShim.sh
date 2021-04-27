#!/bin/sh

###############
#Config section
###############


physicalInterface=bond0
ipAddress=10.1.1.1
routedNet=192.168.10.12/32


###################
#End Config section
###################


###############
#Functions
###############

create_shim () {
	ip link add macvlan-shim link $physicalInterface type macvlan mode bridge
	ip addr add $ipAddress/32 dev macvlan-shim
	ip link set macvlan-shim up
	ip route add $routedNet dev macvlan-shim
}

remove_shim () {
	ip route del $routedNet dev macvlan-shim || true
	ip link set macvlan-shim down || true
	ip addr del $ipAddress/32 dev macvlan-shim || true
	ip link del macvlan-shim || true
}

#################
#End of Functions
#################


#################
#Main Loop
#################

case $1 in

	create)
		if [ -f "/sys/class/net/macvlan-shim/operstate" ]; then
			echo "Shim already exists"
		else 
			echo "Creating shim $physicalInterface:$ipAddress->$routedNet"
			create_shim
		fi
		;;
		
	remove)
		echo "Removing shim"
		remove_shim
		;;
		
	recreate)
		echo "Recreating shim"
		remove_shim
		sleep 1
		create_shim
		;;
		
	*)
		echo "Invalid parameter. Expected 'create', 'delete', or 'recreate'"
		;;
esac