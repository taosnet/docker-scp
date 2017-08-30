## Description

Provides a lightweight base image to access containers via ssh. Only allows access via Public/Private keys, and disallows root access. Two environmental variables are provided to ease the setup and access of the containers: **SSH_USER** and **SSH_AUTH_KEY**. **SSH_USER** is the initial username to setup with access to the container. **SSH_AUTH_KEY** is the users public key to use for authentication. Note that using this container without any sort of volume does not make any sense.

## Usage

To run a simple container:

```
docker run --name myssh -d -v mydata:/data -e SSH_USER=myuser -e SSH_AUTH_KEY=myuserkey... -p 2222:22 taosnet/ssh_server
```

### Scenarios

This container can be used with other containers to provide a backup of docker volumes host to host. Consider the scenario where you want to provide backups of an authoritative name server across hosts:

Consider an authoritative name server running on **Host A**:

```
docker run --name ns1 -d -p 53:53/tcp -p 53:53/udp -v ns1:/etc/pdns/db taosnet/pdns_server
```

First create the keys to use for the backup:

```
docker run --rm -ti -v backup-key:/root/.ssh --entrypoint /bin/sh taosnet/scp
# chmod 700 /root/.ssh
# dropbearkey -t rsa -s 4096 -f /root/.ssh/id_dropbear
# exit
```

Make sure to copy the public key output to for use on **Host B** the backup server:

```
docker run --name ns1-backup -d -p 2222:22 -v ns1:/home/backup/db -e SSH_USER=backup -e 'SSH_AUTH_KEY=public_key_from_above_command_output...' taosnet/ssh_server
docker exec ns1-backup chown backup /home/backup/db
```

To backup the server:

On **Host A**:

You should run the first time interactively to accept the host key from the server on **Host B**.

```
docker run --rm -ti -v backup-key:/root/.ssh -v ns1:/etc/pdns/db taosnet/scp -P 2222 /etc/pdns/db/zones.db backup@hostb:/home/backup/db
```

Subsequent runs can be:
```
docker run --rm -v backup-key:/root/.ssh -v ns1:/etc/pdns/db taosnet/scp -P 2222 /etc/pdns/db/zones.db backup@hostb:/home/backup/db
```

## Environmental Variables

* **SSH_USER** is the username of the initial user to setup.
* **SSH_AUTH_KEY** is the public key of **SSH_USER** to setup Public/Private key authentication with.
