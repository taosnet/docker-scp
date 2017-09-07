#!/bin/sh

usage() {
	>&2 echo "Usage: $0 [-k key] [-g group] username"
	exit 1
}

key=""
group=""
while getopts "g:k:" o; do
	case "${o}" in
		g)
			group="${OPTARG}"
			;;
		k)
			key="${OPTARG}"
			;;
		*)
			usage
			;;
	esac
done
shift $((OPTIND-1))

if [ -z "$1" ]; then usage; fi

user="$1"
if getent passwd "$user" >/dev/null; then
	echo User exists. Adding key to authorized_keys...
	if [ -z "$key" ]; then
		>&2 echo "Error: User already exists. Must specify a key to add to authorized keys!"
		exit 2
	fi
	group=`groups "$user" | cut -d' ' -f1`
	if ! [ -e "/user/$user/.ssh" ]; then
		mkdir "/home/$user/.ssh"
		touch "/home/$user/.ssh/authorized_keys"
		chown -R "$user"."$group" "/home/$user/.ssh"
		chmod 700 "/home/$user/.ssh"
	fi
	if ! [ -e "/home/$user/.ssh/authorized_keys" ]; then
		touch "/home/$user/.ssh/authorized_keys"
		chown "$user"."$group" "/home/$user/.ssh/authorized_keys"
		chmod 600 "/home/$user/.ssh/authorized_keys"
	fi
	echo "$key" >>"/home/$user/.ssh/authorized_keys"
	exit 0
fi

if [ -z "$group" ]; then
	/usr/sbin/adduser -h "/home/$user" -D -s /bin/sh "$user"
else
	if getent group "$group" >/dev/null; then
		/usr/sbin/adduser -h "/home/$user" -G "$group" -D -s /bin/sh "$user"
	else
		>&2 echo "Error: $group is not a valid group name!"
		exit 2
	fi
fi

if [ -n "$key" ]; then
	mkdir -p "/home/$user/.ssh"
	echo "$key" >"/home/$user/.ssh/authorized_keys"
	if [ -n "$group" ]; then
		chown -R "$user"."$group" "/home/$user/.ssh"
	else
		group=`groups "$user" | cut -d' ' -f1`
		chown -R "$user"."$group" "/home/$user/.ssh"
	fi
	chmod 700 "/home/$user/.ssh"
	chmod 600 "/home/$user/.ssh/authorized_keys"
fi
