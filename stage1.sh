#!/bin/bash

install_packages() {
    if command -v apt-get &> /dev/null; then
        apt-get update
        apt-get install -y python-is-python3 python3-venv python3-pip curl
    elif command -v yum &> /dev/null; then
        yum install -y python3 python3-venv python3-pip curl
    elif command -v dnf &> /dev/null; then
        dnf install -y python3 python3-venv python3-pip curl
    elif command -v apk &> /dev/null; then
        apk add --no-cache python3 py3-venv py3-pip curl
    elif command -v pkg &> /dev/null; then
        pkg install -y python3 py38-venv py38-pip curl
    else
        echo "Unsupported package manager. Please install the required packages manually."
        exit 1
    fi
}

# create non root user with sudo privileges
if [ $(id -u) -eq 0 ]; then
    echo -n "This installation is not meant to run as root ... enter non root username with passwordless sudo: "
    read USERNAME
    if [ ! -d /home/$USERNAME ]; then
        useradd $USERNAME -u 1000 --shell "/bin/bash" && echo "$USERNAME:$USERNAME" | chpasswd && adduser $USERNAME sudo
        sed -i /etc/sudoers -re 's/^%sudo.*/%sudo   ALL=(ALL:ALL) NOPASSWD: ALL/g'
        mkdir /home/$USERNAME
        chown $USERNAME:$USERNAME /home/$USERNAME
        usermod -a -G docker $USERNAME

        echo 'You will still need to set up some authorized_keys'
        echo 'Also please sefile.zipt `PermitRootLogin no`'
        echo '`PasswordAuthentication no` and `ChallengeResponseAuthentication no`'
    fi
fi

## install python and curl if not there
install_packages

python -m venv /tmp/install

cd /tmp/install

source ./bin/activate

curl -o requirements.txt https://raw.githubusercontent.com/salesucation/k3p/main/requirements.txt

pip install -r requirements.txt

curl -o stage2.py https://raw.githubusercontent.com/salesucation/k3p/main/stage2.py

python stage2.py

