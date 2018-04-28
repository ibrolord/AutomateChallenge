#!/bin/bash
echo "Automated Openstack Installation "
echo
echo "if you dont want to touch your screen look at the script and replace out the logics with hard variables"
echo
echo "********************************************************"
echo
echo  "This is meant for CentOS at the moment, its recomended to run as root, you are running as $(whoami) "
echo
sleep 3
##get password
#read -p "Do you want to install the allinone  version instead? (if no, all you need I ask is to config your necessary passwords and IP, I chose no cause I dont need all in one " ALLQ

echo "we will need these passwords moving forward"
echo
echo "We will disable demo mode too"
read -s -p "You may want to type your mariadb password bro: " MPASS
read -s -p "You may want to type your nagios password bro: " NPASS
read -s -p "You may want to type your admin password: " KPASS

#read: read [-ers] [-a array] [-d delim] [-i text] [-n nchars] [-N nchars] [-p prompt] [-t timeout] [-u fd] [name ...]

##needed dir for openstak
DIR="$HOME/openst"
if [ ! -d $DIR ]; then
	 mkdir ~/openst/ && cd ~/openst/
else
	cd ~/openst/
fi

##debug
echo -n "Do you want to debug? "
read -r QUES

##send to debug file with line number
if [[ $QUES -eq "y" || $QUES -eq "yes" ]]; then
	exec 5> $DIR/debug.txt
	BASH_XTRACEFD="5"
	PS4='${LINENO}: '
	set -x  
fi

echo "************************************"
#lets see your IP address
echo "Your current ipv4/ipv6 address(es): "
IPADD=$(hostname -I)
for  ip in ${IPADD[*]} ; do
	echo $ip
done
echo "************************************"
echo -n "Do you want to change your IP your current IP is $ip "
read -r IPA

if [[ $IPA -eq "y" || $IPA -eq "yes" ]]; then
	echo -n "Kindly type your IP"
	read -r IP
fi

systemctl stop postfix firewalld NetworkManager
systemctl disable postfix firewalld NetworkManager
systemctl mask NetworkManager
yum remove -y postfix NetworkManager NetworkManager-libnm

cp -f /etc/selinux/config /etc/selinux/config.bak
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

yum install -y ntpdate

##TEST for debug and slow things down
#for i in {1..5}; do
	#statements
#	echo "*"
#	sleep 5
#done

yum update -y

yum install -y https://www.rdoproject.org/repos/rdo-release.rpm 

yum install -y centos-release-openstack-mitaka

if [[ $(echo $?) == 1 ]]; then
	echo " uh oh  "
	ping 8.8.8.8 -c 3

	if [[ $(echo $?) == 1 ]]; then
		echo 'networking problem'
		echo
		fi
fi

yum update -y
yum install -y openstack-packstack
echo "Creating ~/openst/ directory if it does not exist because there is an issue with installing Openstack and I am installing the pythonsetup kit in this directory"

#if [[ $ALLQ -eq "y" || $ALLQ -eq "yes" ]]; then
#	packstack --allinone
#	exit
#fi

LONG=`date +"%d.%m.%y"`.conf

packstack --gen-answer-file=$LONG
if [[ $(echo $?) == 1 ]]; then
	 wget https://bootstrap.pypa.io/ez_setup.py -O - | python
	 
		if [[ $(echo $?) == 1 ]]; then
	 		echo "Bruhh you need to fix your system"
			echo
	 		echo $?
	 	else
	 		packstack --gen-answer-file=$LONG
	 	fi
	 fi
#test -f `date +"%d.%m.%y"` && rm -f 

##backup
cp -f $LONG $LONG.bak

##send password to sed
#sleep 3
sed -i "s/^CONFIG_NTP_SERVERS=.*/CONFIG_NTP_SERVERS=0.ro.pool.ntp.org/; s/^CONFIG_PROVISION_DEMO=.*/CONFIG_PROVISION_DEMO=n/; s/^CONFIG_HORIZON_SSL=.*/CONFIG_HORIZON_SSL=y/; s/^CONFIG_MARIADB_PW=.*/CONFIG_MARIADB_PW=$MPASS/; s/^CONFIG_NAGIOS_PW=.*/CONFIG_NAGIOS_PW=$NPASS/; s/^CONFIG_KEYSTONE_ADMIN_PW=.*/CONFIG_KEYSTONE_ADMIN_PW=$KPASS/; s/^CONFIG_CONTROLLER_HOST=.*/CONFIG_CONTROLLER_HOST==$IP/;" $LONG

##test password and sed success
if [[ $(echo $?) == 1 ]]; then
	echo "Bruh what did you do"
	echo 
	echo -n "Would you like to check your file y/n"
	read ANS
	if [[ $ANS == y || $ANS == yes ]]; then
		if [[ -f `date +"%d.%m.%y"`.conf ]]; then
			echo "The file exists, I dont know what to say to you, check things"
	                exit
		else echo " The gen-answer-file file is missing"
		fi
fi
fi

##continue if that works
packstack --answer-file=$LONG
if [[ $(echo $?) == 1 && $(type -p httpd) ]]; then
	echo "I will disable 443 listen sorry"
	##test for httpd issues
	test -f /etc/httpd/conf.d/ssl.conf && cp -f /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.bak && sed -i "s/'Listen 443 https'/'#Listen 443 https'/" /etc/httpd/conf.d/ssl.conf || echo " Nevermind"
	systemctl restart httpd.service
fi

##cleanup the
