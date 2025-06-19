
describe_machine(){
	CPU_INFO=`cat /proc/cpuinfo | grep -i "^model name" | cut -d ":" -f2 | sed -n '1p'`
	echo "CPU model: $CPU_INFO"
	
	KERNEL_VERSION_UBUNTU=`uname -r`
	KERNEL_VERSION_CENTOS=`uname -r`
	if [ -f /etc/lsb-release ]
	then
		echo "kernel version: $KERNEL_VERSION_UBUNTU"
	else
		echo "kernel version: $KERNEL_VERSION_CENTOS"
	fi
	
	VERSION=`cat /etc/os-release | grep -i ^PRETTY`
	if [ -f /etc/os-release ]
	then
		echo "The system version: $VERSION"
	else
		echo "Dont know system version"
	fi
	
	MEMORY_FREE=`free -m  | grep ^Mem | tr -s ' ' | cut -d ' ' -f 4`
	echo "Memory free is: $MEMORY_FREE"
	
	USAGE=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage ""}')
	echo "CPU Usage : $USAGE"
}
