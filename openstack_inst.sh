#!/bin/bash
echo "Automated Openstack Installation "
echo
echo "if you dont want to touch your screen look at the script and replace out the logics with hard variables"
echo
echo "*******************************************************************************************************"
echo

echo  "this is meant for CentOS at the moment, its recomended to run as root, you are running as $(whoami) "
#echo -n "Do you want to run this run in the background "
#read WHAT
echo

##get password
echo "we will need this passwords moving forward"
echo -n "You may want to type your mariadb password bro: "
read -r MPASS
echo -n "You may want to type your nagios password bro: "
read -r NPASS
echo -n "You may want to type your admin password: "
read -r KPASS


#if [[ $WHAT == 'y' || $WHAT == 'yes' ]]; then
#	echo "This will install screen and run the script in detached mode, you can reattach but you will not see any errors"
#	##verify installation of screen then install
#	command -v screen 
#	##if ! foobar_loc="$(type -p "$foobar_command_name")" || [[ -z $foobar_loc ]]; then
#	##this can do the same job apparently
#
#		if [ $(echo $?) == 1 ]; then
#			yum install -y screen 
#		fi	
#		if [ $(echo $?) == 1 ]; then
#			yum install -y screen 
#		fi	
#		if [ $(echo $?) == 1 ]; then
#			echo "There is an issue installing screen"
#			fi
#
#	 exec screen -dm -S OpenStackInstallation /bin/bash "$0"
#	 ##verify with screen -list
#
#open_di_stack(){

systemctl stop postfix firewalld NetworkManager
systemctl disable postfix firewalld NetworkManager
systemctl mask NetworkManager
yum remove -y postfix NetworkManager NetworkManager-libnm
#setenforce 0
#getenforce

cp -f /etc/selinux/config /etc/selinux/config.bak
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
#hostnamectl set-hostname $HOST

#if ! loc="$(type -p ntp)" || [[ -z $loc ]]; then
 yum install -y ntpdate
#fi

#for i in {1..5}; do
	#statements
#	echo "*"
#	sleep 5
#done

yum install -y https://www.rdoproject.org/repos/rdo-release.rpm 

yum install -y centos-release-openstack-mitaka

if [[ $(echo $?) == 1 ]]; then
	echo " uh oh  "
	ping 8.8.8.8 -c 4

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
fi

packstack --gen-answer-file=`date +"%d.%m.%y"`.conf
if [[ $(echo $?) == 1 ]]; then
	 wget https://bootstrap.pypa.io/ez_setup.py -O - | python
	 
	 	if [[ $(echo $?) == 1 ]]; then
	 		echo "Bruhh you need to fix your system"
			echo
	 		echo $?
	 	else
	 		packstack --gen-answer-file=`date +"%d.%m.%y"`.conf
	 	fi

fi

#test -f `date +"%d.%m.%y"` && rm -f 


##backup
cp -f `date +"%d.%m.%y"`.conf `date +"%d.%m.%y"`.conf.bak

##send password to sed
#sleep 3

sed -i "s/^CONFIG_NTP_SERVERS=.*/c\CONFIG_NTP_SERVERS=0.ro.pool.ntp.org/; s/^CONFIG_PROVISION_DEMO=.*/c\CONFIG_PROVISION_DEMO=n/; s/^CONFIG_HORIZON_SSL=.*/c\CONFIG_HORIZON_SSL=y/; s/^CONFIG_MARIADB_PW=.*/c\CONFIG_MARIADB_PW=$MPASS/; s/^CONFIG_NAGIOS_PW=.*/c\CONFIG_NAGIOS_PW=$NPASS/; s/^CONFIG_KEYSTONE_ADMIN_PW=.*/c\CONFIG_KEYSTONE_ADMIN_PW=$KPASS/" `date +"%d.%m.%y"`.conf


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
packstack --answer-file `date +"%d.%m.%y"`.conf
if [[ $(echo $?) == 1 && $(type -p httpd) ]]; then
	echo "I will disable 443 listen sorry"
	##test for httpd issues
	test -f /etc/httpd/conf.d/ssl.conf && cp -f /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.bak && sed -i "s/'Listen 443 https'/'#Listen 443 https'/" /etc/httpd/conf.d/ssl.conf || echo " Nevermind"
	

systemctl restart httpd.service
fi

#}

