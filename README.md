# AutomateChallenge
Create a hybrid cloud infrastructure and automate any task along the way

The infrastructure will be a Xen Hypervisor with Openstack installed, Windows server running AD, DNS, File Server. AWS will run the linux instance, which is a webserver.

Automation for Openstack will be done with Bash to install and handle errors
Automation in windows will be done with Powershell to install roles, and configure the servers
Automation in AWS will be done with Cloudformation and User data to create the proper resources and deploy them
Automation within linux (AWS) will be python and bash to schedule git push pull, nodejs and apache directory synchronization, and also mainteanance tasks


In the near future Ansible/Puppet/Chef will be deployed
