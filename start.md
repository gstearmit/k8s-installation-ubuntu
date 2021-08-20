# --------------
vagrant up

#----How To Create a Kubernetes Cluster Using Kubeadm on Ubuntu 18.04--------

https://www.digitalocean.com/community/tutorials/how-to-create-a-kubernetes-cluster-using-kubeadm-on-ubuntu-18-04


#----Linux shell script to add a user with a password-------
https://www.cyberciti.biz/tips/howto-write-shell-script-to-add-user.html
https://techexpert.tips/ubuntu/change-user-password-using-script/
https://www.digitalocean.com/community/tutorials/how-to-harden-openssh-on-ubuntu-18-04
https://linuxize.com/post/how-to-set-up-ssh-keys-on-ubuntu-1804/

$ useradd -m -p EncryptedPasswordHere username


#-------terraform kubernetes kwyword-----------

github terraform kubernetes spring boot kafka
github terraform kubernetes wordpress digitalocean


kubeadm join 192.168.235.192:6443 --token zhkyf8.xp3ywpq56w3uppxq     --discovery-token-ca-cert-hash sha256:45c394edea5dd7c0d7f3fe7aa40de45962af68b3cfc120f1a9e504bcc75f24d6

#-----------Cach 1 : shell User pass---------------

# Enable ssh password authentication
echo "[TASK 2] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Enable root ssh login
echo "[TASK 3] Enable ssh root login"
sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

systemctl reload sshd

# Set Root password
echo "[TASK 4] Set root password"
echo root:kubeadmin | chpasswd


#----------Cach 2 : shell add a non-root user ----------------
# add a non-root user

# add user non-interactively
# TODO: fix default shell
useradd -d "/home/$USER_USERNAME" -m $USER_USERNAME
# set password non-interactively
echo "$USER_USERNAME:$USER_PASSWORD" | chpasswd
# add user to correct Ubuntu groups for SSH and sudo
usermod -a -G sudo,ssh $USER_USERNAME
# remove requirement for password to sudo
echo -e "\n$USER_USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# install SSH key and fix permissions on user SSH keys
USER_HOME="/home/$USER_USERNAME"
mkdir "$USER_HOME/.ssh"
echo $USER_SSHKEY > "$USER_HOME/.ssh/authorized_keys"
chmod "$USER_HOME/.ssh/" 600
chmod "$USER_HOME/.ssh" 700
chown -r "$USER_HOME/.ssh" $USER_USERNAME:$USER_USERNAME

# secure SSH from root login
sed -e 's/^.*PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config | tee /etc/ssh/sshd_config
sed -e 's/^.*PasswordAuthentication.*$/PasswordAuthentication no/g' /etc/ssh/sshd_config | tee /etc/ssh/sshd_config

# TODO: add iptables configuration