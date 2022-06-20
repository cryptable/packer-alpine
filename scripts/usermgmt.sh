#!/bin/sh

echo '%wheel ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/wheel
addgroup ${ALPINE_USER_NAME} wheel
echo add ssh key
mkdir -p /home/${ALPINE_USER_NAME}
chown -R ${ALPINE_USER_NAME} /home/${ALPINE_USER_NAME}
cd /home/${ALPINE_USER_NAME}
mkdir .ssh
chmod 700 .ssh
cat /tmp/idpriv.pub >> .ssh/authorized_keys
chown -R ${ALPINE_USER_NAME} .ssh
echo disable ssh root login
sed '/PermitRootLogin yes/d' -i /etc/ssh/sshd_config