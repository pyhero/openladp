#!/bin/bash
#

if [ ! -z $info_file ];then
	info_src=$info_file
else
	info_src=../xconfigs/ldap.info
fi
source $info_src
[ $? -ne 0 ] && exit 2

##. log slapd
logfile=/var/log/slapd.log
cat > /etc/rsyslog.d/slapd.conf << EOF
local4.* $logfile
EOF
touch $logfile && chown -R ldap $logfile
/etc/init.d/rsyslog restart > /dev/null

cat > /etc/openldap/slapd.conf <<EOF
include         /etc/openldap/schema/corba.schema
include         /etc/openldap/schema/core.schema
include         /etc/openldap/schema/cosine.schema
include         /etc/openldap/schema/duaconf.schema
include         /etc/openldap/schema/dyngroup.schema
include         /etc/openldap/schema/inetorgperson.schema
include         /etc/openldap/schema/java.schema
include         /etc/openldap/schema/misc.schema
include         /etc/openldap/schema/nis.schema
include         /etc/openldap/schema/openldap.schema
include         /etc/openldap/schema/ppolicy.schema
include         /etc/openldap/schema/collective.schema

include         /etc/openldap/schema/smartauth.schema

allow bind_v2

pidfile         /var/run/openldap/slapd.pid
argsfile        /var/run/openldap/slapd.args
loglevel	772

access to dn.base="" by * read
access to dn.base="cn=Subschema" by * read
access to *
        by self write
        by users read
        by anonymous auth

database config
access to *
        by dn.exact="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage
        by * none

database monitor
access to *
        by dn.exact="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read
        by dn.exact="$ROOT_DN" read
        by * none

database        bdb
suffix          "$DN"
checkpoint      1024 15
rootdn          "$ROOT_DN"
rootpw          $password

access to attrs=userPassword
	by self write
	by anonymous auth
	by * none
access to attrs=mail,mobileNumber,email
	by self write
	by * read
access to *
	by * read

directory       /var/lib/ldap

index objectClass                       eq,pres
index uidNumber,gidNumber,loginShell    eq,pres
index ou,cn,mail,surname,givenname      eq,pres,sub
index uid,memberUid                     eq,pres,sub
index nisMapName,nisMapEntry		eq,pres,sub
index isvalid						eq,pres
index allowssh,allowvpn,allowsvn,allowgit		eq,pres
index memberOf						eq,pres

TLSCACertificatePath /etc/openldap/certs
TLSCertificateFile "\"OpenLDAP Server\""
TLSCertificateKeyFile /etc/openldap/certs/password

TLSCACertificateFile /etc/openldap/certs/ca.crt
TLSCertificateFile /etc/openldap/certs/ldap.crt
TLSCertificateKeyFile /etc/openldap/certs/ldap.key
TLSVerifyClient never
EOF

cat > /etc/openldap/schema/smartauth.schema << EOF
attributetype ( 1.3.6.1.4.1.45604.1.0 NAME 'isvalid'
        DESC 'account flag'
        EQUALITY booleanMatch
        SYNTAX 1.3.6.1.4.1.1466.115.121.1.7 SINGLE-VALUE)

attributetype ( 1.3.6.1.4.1.45604.1.1 NAME 'allowssh'
        DESC 'allow ssh'
        EQUALITY booleanMatch
        SYNTAX 1.3.6.1.4.1.1466.115.121.1.7 SINGLE-VALUE)

attributetype ( 1.3.6.1.4.1.45604.1.2 NAME 'allowvpn'
        DESC 'allow vpn'
        EQUALITY booleanMatch
        SYNTAX 1.3.6.1.4.1.1466.115.121.1.7 SINGLE-VALUE)

attributetype ( 1.3.6.1.4.1.45604.1.3 NAME 'allowsvn'
        DESC 'allow svn'
        EQUALITY booleanMatch
        SYNTAX 1.3.6.1.4.1.1466.115.121.1.7 SINGLE-VALUE)

attributetype ( 1.3.6.1.4.1.45604.1.4 NAME 'allowgit'
        DESC 'allow git'
        EQUALITY booleanMatch
        SYNTAX 1.3.6.1.4.1.1466.115.121.1.7 SINGLE-VALUE)

attributetype ( 1.3.6.1.4.1.45604.1.5 NAME 'mobileNumber'
        DESC 'The mobile field'
        EQUALITY caseIgnoreIA5Match
        SUBSTR caseIgnoreIA5SubstringsMatch
        SYNTAX 1.3.6.1.4.1.1466.115.121.1.26{12} SINGLE-VALUE )

attributetype ( 1.3.6.1.4.1.45604.1.6 NAME 'memberOf'
        DESC 'member of group'
        EQUALITY caseIgnoreMatch
        SUBSTR caseExactIA5SubstringsMatch
        SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 )

# Object Class Definitions

objectclass ( 1.3.6.1.4.1.45604.2.0 NAME 'smartAccount'
        DESC 'Abstraction of an account with SmartAuth attributes'
        SUP top AUXILIARY
        MUST ( isvalid $ allowvpn $ allowssh $ allowgit $ allowsvn)
        MAY ( email $ mobileNumber $ memberOf ) )
EOF

cat > /etc/openldap/schema/smartauth.ldif << EOF
dn: cn=smartauth,cn=schema,cn=config
objectClass: olcSchemaConfig
cn: smartauth
olcAttributeTypes: (1.3.6.1.4.1.45604.1.0 NAME 'email' DESC 'The email field, work email' EQUALITY caseIgnoreIA5Match SUBSTR caseIgnoreIA5SubstringsMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.26{128} SINGLE-VALUE )
olcAttributeTypes: (1.3.6.1.4.1.45604.1.5 NAME 'mobile' DESC 'The mobile field' EQUALITY caseIgnoreIA5Match SUBSTR caseIgnoreIA5SubstringsMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.26{12} SINGLE-VALUE )
olcAttributeTypes: ( 1.3.6.1.4.1.45604.1.0 NAME 'isvalid' DESC 'account flag' SYNTAX 1.3.6.1.4.1.1466.115.121.1.7)
olcAttributeTypes: ( 1.3.6.1.4.1.45604.1.1 NAME 'allowssh' DESC 'allow ssh' SYNTAX 1.3.6.1.4.1.1466.115.121.1.7)
olcAttributeType: ( 1.3.6.1.4.1.45604.1.2 NAME 'allowvpn' DESC 'allow vpn' SYNTAX 1.3.6.1.4.1.1466.115.121.1.7)
olcAttributeTypes: ( 1.3.6.1.4.1.45604.1.3 NAME 'allowsvn' DESC 'allow svn' SYNTAX 1.3.6.1.4.1.1466.115.121.1.7)
olcAttributeTypes: ( 1.3.6.1.4.1.45604.1.4 NAME 'allowgit' DESC 'allow git' SYNTAX 1.3.6.1.4.1.1466.115.121.1.7)
olcAttributeTypes: ( 1.3.6.1.4.1.45604.1.6 NAME 'memberOf' DESC 'member of group' SYNTAX 1.3.6.1.4.1.1466.115.121.1.15)
olcObjectClasses: ( 1.3.6.1.4.1.45604.2.0 NAME 'smartAccount' DESC 'Abstraction of an account with SmartAuth attributes' SUP top AUXILIARY MUST ( isvalid $ allowvpn $ allowssh $ allowgit $ allowsvn) MAY ( email $ mobileNumber $ memberOf) )
EOF

cat > /var/lib/ldap/DB_CONFIG << EOF
set_cachesize 0 268435456 1
# Data Directory
#set_data_dir db

# Transaction Log settings
set_lg_regionmax 262144
set_lg_bsize 2097152
#set_lg_dir logs
EOF
chown ldap.ldap /var/lib/ldap/DB_CONFIG

rm -rf /etc/openldap/slapd.d
mkdir /etc/openldap/slapd.d
slapcat -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d -n0 > /dev/null
[ $? -ne 0 ] && exit 2
chown -R ldap:ldap /etc/openldap/slapd.d

service slapd restart
