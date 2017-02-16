#!/bin/bash
#

DIR=$(cd `dirname $0`;echo $PWD)
yum -q -y install httpd php php-bcmath php-gd php-mbstring php-xml php-ldap phpldapadmin

TODAY=$($(which date) "+%Y%m%d")
CONF_DIR=$DIR/../xconfigs/phpldapadmin
PLA_CONF=$CONF_DIR/config.php
PLA_CONF_ONLINE=/etc/phpldapadmin/config.php
PLA_APACHE=$CONF_DIR/phpldapadmin.conf
PLA_APACHE_ONLINE=/etc/httpd/conf.d/phpldapadmin.conf
PLA_NGINX=$CONF_DIR/pla.aiuv.cc.conf
PLA_NGINX_ONLINE=/ROOT/conf/nginx/conf-noc/pla.aiuv.cc.conf

cp $PLA_CONF_ONLINE ${PLA_CONF_ONLINE}.$TODAY
rsync -az $PLA_CONF $PLA_CONF_ONLINE

rsync -az $PLA_APACHE $PLA_APACHE_ONLINE

rsync -az $PLA_NGINX $PLA_NGINX_ONLINE
