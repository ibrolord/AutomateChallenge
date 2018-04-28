#!/bin/bash
echo "Automated Openstack Installation "
echo
echo "if you dont want to touch your screen look at the script and replace out the logics with hard variables"
echo
echo "********************************************************"
echo
echo  "this is meant for CentOS at the moment, its recomended to run as root, you are running as $(whoami) "
echo

##I see the echo I could have used \n I know dont judge

##get password
echo "we will need these passwords moving forward"
echo -n "You may want to type your mariadb password bro: "
read -s MPASS
echo -n "n You may want to type your nagios password bro: "
read -s NPASS
echo -n "n You may want to type your admin password: "
read -s KPASS


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

if [[ $QUES -eq "y" || $QUES -eq "yes" ]]; then
	exec 5> $DIR/debug.txt
	BASH_XTRACEFD="5"
	PS4='LINENO: '
	set -x  
fi

#lets see your IP address
#IPADD=$(hostname -I)
#for ( ip in ${IPADD[*]} ); do
#	$ip
#done

#echo -n "Do you want to change your IP your current IP is $ip "
#sleep 5

#read -r $IP
##	echo -n "Kindly type your IP"
#fi

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

DIR="$HOME/openst/"
if [ ! -d $DIR ]; then
	 mkdir ~/openst/ && cd ~/openst/
else
	cd ~/openst/
fi

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
cp -f $LONG $LONG.dbg
sed -i "s/^CONFIG_NTP_SERVERS=.*/c\CONFIG_NTP_SERVERS=0.ro.pool.ntp.org/; s/^CONFIG_PROVISION_DEMO=.*/c\CONFIG_PROVISION_DEMO=n/; s/^CONFIG_HORIZON_SSL=.*/c\CONFIG_HORIZON_SSL=y/; s/^CONFIG_MARIADB_PW=.*/c\CONFIG_MARIADB_PW=$MPASS/; s/^CONFIG_NAGIOS_PW=.*/c\CONFIG_NAGIOS_PW=$NPASS/; s/^CONFIG_KEYSTONE_ADMIN_PW=.*/c\CONFIG_KEYSTONE_ADMIN_PW=$KPASS/" $LONG

cp $LONG $LONG.dbg2
cp -f $LONG.dbg2 $LONG
cp -f $LONG.dbg2 $LONG.bro
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
#sed -i "s/^CONFIG_NTP_SERVERS=.*/c\CONFIG_NTP_SERVERS=0.ro.pool.ntp.org/; s/^CONFIG_PROVISION_DEMO=.*/c\CONFIG_PROVISION_DEMO=n/; s/^CONFIG_HORIZON_SSL=.*/c\CONFIG_HORIZON_SSL=y/; s/^CONFIG_MARIADB_PW=.*/c\CONFIG_MARIADB_PW=$MPASS/; s/^CONFIG_NAGIOS_PW=.*/c\CONFIG_NAGIOS_PW=$NPASS/; s/^CONFIG_KEYSTONE_ADMIN_PW=.*/c\CONFIG_KEYSTONE_ADMIN_PW=$KPASS/" `date +"%d.%m.%y"`.conf
##the second sed was added out of frustrtion, I could not figure out what kept overwriting the answer files
