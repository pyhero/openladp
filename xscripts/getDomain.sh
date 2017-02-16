#!/bin/bash
#

##. Get name: DN & ROOT_DN
while read -p "Input your DOMAIN NAME,like aiuv.cc: " DOMAIN_NAME;do
	echo -e "Your domain name is: \e[32m$DOMAIN_NAME\e[0m"
	while read -p "Confirm {y|n}: " inp;do
		case $inp in
			y|Y)
				rev=0
				break
				;;
			n|N)
				rev=1
				break
				;;
			*)
				continue
		esac

	done
	if [ $rev == 0 ];then
		break
	else
		continue
	fi
done

[ -z $DOMAIN_NAME ] && DOMAIN_NAME="aiuv.cc"

##. Define DN
DN=$(echo $DOMAIN_NAME | awk -F'.' '{i=1;while(i<=NF){print "dc="$i;i++}}' | sed ':t;N;s/\n/,/;b t')
ROOT_DN="cn=root,$DN"
DC_NAME=$(echo $DOMAIN_NAME | awk -F'.' '{print $1}')
HOSTNAME_FQDN="ldap.$DOMAIN_NAME"
