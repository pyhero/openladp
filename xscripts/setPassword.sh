#!/bin/bash
#

if ! which slappasswd &>/dev/null;then
	echo -e "Command \e[31;5mslappasswd\e[0m not find.\nThis may \e[31;5mopenldap-servers\e[0m not install successfully!"
	exit 2
else
	while :;do
		echo -e "Input password for \e[32mroot\e[0m..."
		password=$(slappasswd)
		[ $? -eq 0 ] && break
	done
fi
