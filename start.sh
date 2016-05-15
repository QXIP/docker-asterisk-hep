#!/bin/sh -x

HEP_IP=${HEP_IP:-"127.0.0.1"}
HEP_PORT=${HEP_PORT:-"127.0.0.1"}
#sed -i "s/advertised_address=.*/advertised_address=\"${HEP_IP}\"/g" /etc/asterisk/hep.conf
#sed -i "s/advertised_address=.*/advertised_address=\"${HEP_PORT}\"/g" /etc/asterisk/hep.conf

echo "Starting Asterisk..."
tail -f /var/log/asterisk/messages &&
/usr/sbin/asterisk -fvvvvvvv
