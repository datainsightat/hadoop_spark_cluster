#!/usr/bin/env bash

function createSSHKey {
    echo "generating ssh keys..."
    ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    cp -f /vagrant/resources/ssh/sshd_config /etc/ssh
    cp -f /vagrant/resources/ssh/config ~/.ssh
    sudo chmod 777 ~/.ssh/authorized_keys
    systemctl restart sshd
}

function sshCopyId {
    HOSTS=(body slave1 slave2)
    for node in "${HOSTS[@]}"
    do
        echo "setting up key for $node"
        sshpass -p vagrant ssh-copy-id -i ~/.ssh/id_rsa.pub ${node}
    done
    ssh-keyscan -t rsa,dsa body, slave1, slave2 > ~/.ssh/known_hosts
}

echo "Setting up remote ssh for HEAD..."
createSSHKey
sshCopyId
