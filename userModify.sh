#!/bin/bash
#

[ $# -lt 1 ] && exit 2
USER=$1
LDAP_URI="ldap://ldap.noc.aiuv.com"

DIR=$(cd `dirname $0`;echo $PWD)
module=$DIR/xconfigs/modify.ldif
passwd_file=$DIR/xconfigs/.pa
get_new_uidNumber () {
	LAST_UID=$(ldapsearch -H $LDAP_URI -b dc=noc,dc=aiuv,dc=com -x "uidNumber" | grep "^uidNumber:" | awk '{print $2}' | sort -n | tail -n1)
	uidNumber=$[$LAST_UID+1]
}

GID_MAP () {
	SUPER=7000
	COMMON=7001
	SA=7002
	DEV=7003
	DBA=7004
	DEFAULT_GID=$COMMON
}

gidNumber=7002
##. Generate ldif

get_new_uidNumber
/usr/bin/ldapmodify -H $LDAP_URI -f $module -D cn=root,dc=noc,dc=aiuv,dc=com -w $(cat $passwd_file)
