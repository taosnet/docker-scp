#!/bin/sh

if ! [ -d /etc/dropbear ]; then
	mkdir /etc/dropbear
	/usr/bin/dropbearkey -t rsa -s 4096 -f /etc/dropbear/dropbear_rsa_host_key
	/usr/bin/dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key
	if [ -n "$SSH_USER" ]; then
		/usr/sbin/adduser -h /home/$SSH_USER -D -s /bin/sh $SSH_USER
		if [ -n "$SSH_AUTH_KEY" ]; then
			mkdir /home/$SSH_USER/.ssh
			echo "$SSH_AUTH_KEY" >/home/$SSH_USER/.ssh/authorized_keys
			chown -R "$SSH_USER".$SSH_USER /home/$SSH_USER/.ssh
			chmod 700 /home/$SSH_USER/.ssh
			chmod 600 /home/$SSH_USER/.ssh/authorized_keys
		fi
	fi
fi

/usr/sbin/dropbear -d /etc/dropbear/dropbear_dss_host_key -r /etc/dropbear/dropbear_rsa_host_key -F -E -w -s -p 22 -K 30
