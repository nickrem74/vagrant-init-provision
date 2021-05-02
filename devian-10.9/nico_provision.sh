#!/bin/bash

## ? Install debian10

IP=$(hostname -I | awk '{print $2}')

echo ""
echo ""
echo "START - install vm - "$IP


sleep 1
echo ""
echo "[1]: install tools"
apt-get install -y git sshpass wget jq gnupg2 curl &>/dev/null
apt-get install -y sharutils net-tools zip unzip &>/dev/null
apt-get install -y lsb-release python3 ansible &>/dev/null


sleep 1
echo ""
echo "[2]: install & enable avahi-daemon"
apt-get install -y avahi-daemon avahi-utils avahi-ui-utils &>/dev/null
sed -i 's|files mdns4_minimal [NOTFOUND=return] dns myhostname|files dns myhostname mdns4_minimal [NOTFOUND=return]|g' /etc/nsswitch.conf
systemctl daemon-reload &>/dev/null
systemctl start avahi-daemon &>/dev/null
systemctl enable avahi-daemon &>/dev/null


sleep 1
echo ""
echo "[3]: install firewalld"
apt-get install -y firewalld &>/dev/null
systemctl start firewalld &>/dev/null
firewall-cmd --add-service=mdns --permanent &>/dev/null
firewall-cmd --add-service=dns --permanent &>/dev/null
firewall-cmd --reload &>/dev/null


sleep 1
echo ""
echo "[4]: set SELINUX permissive"
apt-get install -y selinux-basics selinux-policy-default &>/dev/null
selinux-activate &>/dev/null


sleep 1
echo ""
echo "[5]: set prompt and ls variables"
#echo "" >> /etc/profile
#echo "export PS1=\"\u@\[\033[01;94m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ \"" >> /etc/bashrc
echo "" >> /etc/profile.d/00-aliases.sh
echo "alias ls='ls --color=auto'" >> /etc/profile.d/00-aliases.sh
echo "alias ll='ls -ltr --color=auto'" >> /etc/profile.d/00-aliases.sh
echo "alias la='ls -ltra --color=auto'" >> /etc/profile.d/00-aliases.sh

source /etc/profile.d/00-aliases.sh &>/dev/null


sleep 1
echo ""
echo "[6]: enable PATH for user"
sed -i 's|/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games|/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games|g' /etc/profile
source /etc/profile


sleep 1
echo ""
echo "[6]: enable root login ssh"
sed -i 's|#PermitRootLogin prohibit-password|PermitRootLogin yes|g' /etc/ssh/sshd_config
systemctl restart sshd &>/dev/null


sleep 1
echo ""
echo "[7]: enable locale & keymap FR"
timedatectl set-timezone Europe/Paris &>/dev/null
localectl set-locale LANG=fr_FR.utf8 &>/dev/null
localectl set-keymap fr &>/dev/null
localectl set-x11-keymap fr &>/dev/null


sleep 1
echo ""
echo "[8]: install & enable docker"
apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common  &>/dev/null
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - &>/dev/null
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" &>/dev/null
apt update &>/dev/null
apt-cache policy docker-ce &>/dev/null
apt install -y docker-ce &>/dev/null
#groupadd docker
usermod -aG docker vagrant &>/dev/null
systemctl start docker &>/dev/null
systemctl enable docker &>/dev/null


sleep 1
echo ""
echo "[9]: install & enable docker-compose"
DOCKER_COMPOSE_VERS="1.29.0"
sudo curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERS}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod 755 /usr/local/bin/docker-compose

sleep 1
echo ""
echo "[10]: general upgrade before reboot"
apt upgrade -y >/dev/null


sleep 1
echo ""
echo "[12]: system reboot"
reboot


echo ""
echo ""
echo "END - install vm - "$IP

