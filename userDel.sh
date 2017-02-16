#!/bin/bash
#

[ $# -lt 1 ] && exit 2
USER=$1
LDAP_URI="ldap://ldap.noc.aiuv.com"

DIR=$(cd `dirname $0`;echo $PWD)
module=$DIR/xconfigs/module.ldif
passwd_file=$DIR/xconfigs/.pa

/usr/bin/ldapdelete -H $LDAP_URI cn=$USER,ou=Accounts,dc=noc,dc=aiuv,dc=com -D cn=root,dc=noc,dc=aiuv,dc=com -w $(cat $passwd_file)
