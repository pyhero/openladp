#!/bin/bash
#

if [ ! -z $info_file ];then
	info_src=$info_file
else
	info_src=../xconfigs/ldap.info
fi
source $info_src
[ $? -ne 0 ] && exit 2

CERT_DIR=/etc/openldap/certs

#CERT_SCRIPT_NAME="generate-server-cert.sh"
#if [ -f ./$CERT_SCRIPT_NAME ];then
#	CERT_SCRIPT="./$CERT_SCRIPT_NAME"
#else
#	CERT_SCRIPT="$script_dir/$CERT_SCRIPT_NAME"
#fi
#
#[ ! -x $CERT_SCRIPT ] && echo "$CERT_SCRIPT check failed" && exit 2
#sed -i	"/^HOSTNAME_FQDN/s/.*/HOSTNAME_FQDN=\"$HOSTNAME_FQDN\"/; \
#	/^CERT_KEY_SIZE/s/.*/CERT_KEY_SIZE=2048/; \
#	/^CERT_VALID_MONTHS/s/.*/CERT_VALID_MONTHS=1198/" \
#	$CERT_SCRIPT
#sh $CERT_SCRIPT

echo 01 > /etc/pki/CA/serial
rm -rf /etc/pki/CA/index.txt && touch /etc/pki/CA/index.txt

cd $CERT_DIR
echo -e "\n\nGenerate certs: ..."
# common name must be your server domain name:
##. CA
#. key
openssl genrsa -des3 -out ca.sec.key -passout pass:PanDaNB007 2048
openssl rsa -in ca.sec.key -passin pass:PanDaNB007 -out ca.key && rm -rf ca.sec.key
#. ca
openssl req -new -x509 -key ca.key -out ca.crt -days 36500 -subj "/C=CN/ST=BJ/L=BJ/O=SA/OU=NOC/CN=$DOMAIN_NAME"

##. CRT
#. key
openssl genrsa -des3 -out ldap.sec.key -passout pass:PanDaNB001 2048
openssl rsa -in ldap.sec.key -passin pass:PanDaNB001 -out ldap.key && rm -rf ldap.sec.key
#. csr
openssl req -new -key ldap.key -out ldap.csr -subj "/C=CN/ST=BJ/O=SA/OU=NOC/CN=ldap.$DOMAIN_NAME"
#. crt
openssl ca -in ldap.csr -out ldap.crt -cert ca.crt -keyfile ca.key -days 3650
chown -R ldap .

##. verify
openssl verify -purpose sslserver -CAfile ca.crt ldap.crt

##. openssl hash
for file in ca.crt ldap.crt;do
	HASH=$(openssl x509 -noout -hash -in $file)
	[ ! -L ${HASH}.0 ] && ln -s $file ${HASH}.0 
done
chown -R ldap.ldap $CERT_DIR
chmod -R 660 $CERT_DIR

rsync -az $CERT_DIR/ca.crt $config_dir/
sed -i '/^SLAPD_LDAPS=/s/no/yes/;/^SLAPD_LDAPI=/s/yes/no/' /etc/sysconfig/ldap
