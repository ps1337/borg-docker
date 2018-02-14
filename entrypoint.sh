#!/bin/bash

if [ "x$1" = "xstart" ]; then
    # Check if we have the authorized_keys file
    if [ ! -f "/home/borg/.ssh/authorized_keys" ]; then
	echo "Missing authorized_keys file. Won't continue."
	exit 1
    fi

    # Ensure that key files of the server exists
    if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
	echo "INFO: No SSH host key present, creating them..."
	/usr/bin/ssh-keygen -A
    fi

    # Ensure that /var/backups/borg is for "us"
    if [ ! -d "/var/backups/borg" ]; then
	echo "Missing repository folder at /var/backups/borg. Won't continue."
	exit 1
    fi
    if [ "`ls -ld /var/backups/borg | awk '{print $3}'`" != "borg" ]; then
	chown borg.borg /var/backups/borg
	chmod 750 /var/backups/borg
    fi

    # Launch ssh server as daemon
    exec /usr/sbin/sshd -D
else
    echo "Unknown argument: $@"
    exit 2
fi
