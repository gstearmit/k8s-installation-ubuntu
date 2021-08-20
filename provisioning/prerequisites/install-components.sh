#!/bin/bash

set -e  # stop immediately if any error happens

SCRIPT_HOME=$(cd `dirname $BASH_SOURCE` && pwd)
POD_IP_RANGE="192.168.0.0/16"  # This IP Range is the default value of Calico

K8S_VERSION="1.16.4-00" # K8s is changed regularly. I just want to keep this script stable with v1.16


apt-get update -y
apt-get install figlet -y

figlet PREREQUISITES

echo "------Start Install  prerequisites\install.sh -----------"

echo "[TASK 1] Add hosts to etc/hosts"
cat >>/etc/hosts<<EOF
100.10.10.100 k8s-master.k8s-phuchc.local
100.10.10.101 k8s-worker-1.k8s-phuchc.local
100.10.10.102 k8s-worker-2.k8s-phuchc.local
100.10.10.103 k8s-worker-3.k8s-phuchc.local
EOF

echo "[TASK 2] Disable Swap"
swapoff -a && sed -i '/swap/d' /etc/fstab

SWAP_MEM=$(cat /proc/meminfo | grep 'SwapTotal' | cut -d":" -f2 | xargs | cut -d" " -f1)
if [[ ! $SWAP_MEM -eq 0 ]]; then
    echo "ERROR: cannot turn of swap memory on this node."
    exit 1
fi

apt-get update
apt install -y apt-transport-https ca-certificates curl software-properties-common -y


echo "[TASK 3] openssh-server"

apt-get install openssh-server -y

echo "[TASK 4] Install Docker"
apt-get update 
apt-get install -y docker.io
apt-get update && apt-get install -y apt-transport-https curl

echo "--> STEP 02. install Docker"  # ref https://kubernetes.io/docs/setup/production-environment/container-runtimes/
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/docker.list
deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable
EOF

sudo apt-get update
sudo apt remove -y docker docker-engine docker.io
sudo apt-get update -y
sudo apt-get install -y \
  containerd.io=1.2.10-3 \
  docker-ce=5:19.03.4~3-0~ubuntu-$(lsb_release -cs) \
  docker-ce-cli=5:19.03.4~3-0~ubuntu-$(lsb_release -cs)
sudo usermod -aG docker $USER

# Setup daemon.
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sudo mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
sudo systemctl daemon-reload
sudo systemctl restart docker



echo "[TASK 5] Add Kubernetes Repositories + install Kubernetes components"
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update




echo "[TASK 6] Install kubelet/kubeadm/kubectl"
# apt-get install -y kubelet kubeadm kubectl 

sudo apt-get install -y kubeadm=$K8S_VERSION kubelet=$K8S_VERSION kubectl=$K8S_VERSION
sudo apt-mark hold kubeadm kubelet kubectl  # Choose to stop upgrading
systemctl enable kubelet
systemctl start kubelet

# Init the cluster
echo "---> Init the cluster"
sudo kubeadm init --ignore-preflight-errors all --pod-network-cidr=$POD_IP_RANGE --upload-certs | tee kubeadm-init.out


echo "--> install sed : Tìm và thay thế chuỗi ký tự trong một file "
apt-get install sed -y

# https://www.edureka.co/blog/install-kubernetes-on-ubuntu
echo "--> Updating Kubernetes Configuration : Cập nhật cấu hình Kubernetes"
sed -i 's/cgroup-driver=systemd/cgroup-driver=cgroupfs/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

echo "------End Install  prerequisites\install.sh -----------"
