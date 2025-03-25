#!/bin/sh

prepare_user() {
    addgroup -g "$3" "$1"
    adduser -D -u "$2" -G "$1" "$1" -s /bin/sh

    echo "$1:*" | chpasswd -e 2> /dev/null

    mkdir -p "/home/$1/.ssh"

    echo "$4" >> "/home/$1/.ssh/authorized_keys"

    chown -R "$1:$1" "/home/$1"
    chmod -R 500 "/home/$1"
}

prepare_user "$PUSH_USER_NAME" "$PUSH_USER_UID" "$PUSH_USER_GID" "$PUSH_USER_AUTHORIZED_KEYS"
prepare_user "$PULL_USER_NAME" "$PULL_USER_UID" "$PULL_USER_GID" "$PULL_USER_AUTHORIZED_KEYS"

chown "$PUSH_USER_NAME:$PUSH_USER_NAME" /data
chmod 755 /data

mkdir -p /etc/ssh/keys

if [ ! -s /etc/ssh/keys/ssh_host_rsa_key ]; then
    ssh-keygen -q -t rsa -f /etc/ssh/keys/ssh_host_rsa_key -N ""
fi

if [ ! -s /etc/ssh/keys/ssh_host_ecdsa_key ]; then
    ssh-keygen -q -t ecdsa -f /etc/ssh/keys/ssh_host_ecdsa_key -N ""
fi

if [ ! -s /etc/ssh/keys/ssh_host_ed25519_key ]; then
    ssh-keygen -q -t ed25519 -f /etc/ssh/keys/ssh_host_ed25519_key -N ""
fi

chown -R root:root /etc/ssh/keys
chmod 700 /etc/ssh/keys

chmod 600 /etc/ssh/keys/*
chmod 644 /etc/ssh/keys/*.pub

cat <<EOF > /etc/ssh/sshd_config
Port 22

HostKey /etc/ssh/keys/ssh_host_rsa_key
HostKey /etc/ssh/keys/ssh_host_ecdsa_key
HostKey /etc/ssh/keys/ssh_host_ed25519_key

SyslogFacility AUTH
LogLevel INFO

LoginGraceTime 2m
StrictModes yes
MaxAuthTries 6
MaxSessions 10

PermitRootLogin no
PermitEmptyPasswords no

PubkeyAuthentication yes
PasswordAuthentication no
HostbasedAuthentication no
KbdInteractiveAuthentication no

AllowTcpForwarding no
GatewayPorts no
X11Forwarding no
EOF

exec "$@"