#!/bin/bash
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

echo "[TASK 3] openssh-server"
apt-get install openssh-server -y

echo "[TASK 4] Install Docker"
apt-get update 
apt-get install -y docker.io
apt-get update && apt-get install -y apt-transport-https curl

echo "[TASK 5] Add Kubernetes Repositories"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update

echo "[TASK 6] Install kubelet/kubeadm/kubectl"
apt-get install -y kubelet kubeadm kubectl 
systemctl enable kubelet
systemctl start kubelet


echo "--> install sed : Tìm và thay thế chuỗi ký tự trong một file "
apt-get install sed -y

# https://www.edureka.co/blog/install-kubernetes-on-ubuntu
echo "--> Updating Kubernetes Configuration : Cập nhật cấu hình Kubernetes"
sed -i 's/cgroup-driver=systemd/cgroup-driver=cgroupfs/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

echo "------End Install  prerequisites\install.sh -----------"
