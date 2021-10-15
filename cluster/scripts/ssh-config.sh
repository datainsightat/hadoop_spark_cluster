#!/usr/bin/env bash


function enableSSHPassword {
    echo "generating ssh keys..."
    ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    cp -f /vagrant/resources/ssh/sshd_config /etc/ssh
    cp -f /vagrant/resources/ssh/config ~/.ssh/
    sudo chmod 777 ~/.ssh/authorized_keys
    systemctl restart sshd
}

echo "Setting up Password Authentication"
enableSSHPassword
