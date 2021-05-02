#!/bin/bash

## ? Install centos7

IP=$(hostname -I | awk '{print $2}')

echo ""
echo ""
echo "START - install vm - "$IP


sleep 1
echo ""
echo "[1]: install epel-release"
yum clean all >/dev/null
yum update > /dev/null
yum install -y yum-utils > /dev/null
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#yum install -y epel-release


sleep 1
echo ""
echo "[2]: install tools"
yum install -y git sshpass wget jq gnupg2 curl >/dev/null
yum install -y sharutils net-tools dnf zip unzip >/dev/null
yum install -y redhat-lsb-core python3 ansible >/dev/null


sleep 1
echo ""
echo "[3]: install & enable avahi-daemon"
yum install -y avahi avahi-tools avahi-ui-tools >/dev/null
sed -i 's|myhostname|myhostname mdns4_minimal [NOTFOUND=return]|g' /etc/nsswitch.conf
systemctl daemon-reload >/dev/null
systemctl start avahi-daemon &>/dev/null
systemctl enable avahi-daemon &>/dev/null


sleep 1
echo ""
echo "[4]: install firewalld"
yum install -y firewalld >/dev/null
systemctl start firewalld &>/dev/null
firewall-cmd --add-service=mdns --permanent &>/dev/null
firewall-cmd --add-service=dns --permanent &>/dev/null
firewall-cmd --reload &>/dev/null


sleep 1
echo ""
echo "[5]: set SELINUX permissive"
sed -i 's|SELINUX=enforcing|SELINUX=permissive|g' /etc/selinux/config
sed -i 's|SELINUX=disabled|SELINUX=permissive|g' /etc/selinux/config


sleep 1
echo ""
echo "[6]: set prompt and ls variables"
echo "" >> /etc/bashrc
echo "export PS1=\"\u@\[\033[01;94m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ \"" >> /etc/bashrc
echo "" >> /etc/bashrc
echo "alias ls='ls --color=auto'" >> /etc/bashrc
echo "alias ll='ls -ltr --color=auto'" >> /etc/bashrc
echo "alias la='ls -ltra --color=auto'" >> /etc/bashrc

source /etc/bashrc >/dev/null


sleep 1
echo ""
echo "[7]: enable root login ssh"
sed -i 's|#PermitRootLogin yes|PermitRootLogin yes|g' /etc/ssh/sshd_config
systemctl restart sshd &>/dev/null


sleep 1
echo ""
echo "[8]: enable locale & keymap FR"
timedatectl set-timezone Europe/Paris >/dev/null
localectl set-locale LANG=fr_FR.utf8 >/dev/null
localectl set-keymap fr >/dev/null
localectl set-x11-keymap fr >/dev/null


sleep 1
echo ""
echo "[9]: install & enable docker"
yum install -y device-mapper-persistent-data lvm2 >/dev/null
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo >/dev/null
yum install -y docker >/dev/null
systemctl start docker &>/dev/null
systemctl enable docker &>/dev/null


sleep 1
echo ""
echo "[10]: install & enable docker-compose"
DOCKER_COMPOSE_VERS="1.29.0"
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERS}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose &>/dev/null
chmod 755 /usr/local/bin/docker-compose >/dev/null

sleep 1
echo ""
echo "[11]: general upgrade before reboot"
yum upgrade -y >/dev/null


sleep 1
echo ""
echo "[12]: system reboot"
reboot


echo ""
echo ""
echo "END - install vm - "$IP

