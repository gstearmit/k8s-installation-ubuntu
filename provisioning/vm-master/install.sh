#!/bin/bash

figlet MASTER

echo "------Start Install  vm-master\install.sh -----------"


echo "[TASK 2] Start master"
kubeadm init --ignore-preflight-errors all --apiserver-advertise-address=100.10.10.100  --pod-network-cidr=10.244.0.0/16 --token-ttl 0


echo "[TASK 3] Install kubeconfig"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl get pods -o wide --all-namespaces


echo "[TASK 4] Install Calico"
kubectl apply -f https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml 


echo "[TASK 5] Display PODS"
kubectl get pods --all-namespaces


echo "[TASK 6] Install Dashboard"
kubectl apply -f kubernetes-dashboard.yaml
kubectl apply -f kubernetes-dashboard-rbac.yaml

echo "[TASK 7] Display All Services"
kubectl get services -n kube-system 

kubectl proxy

# http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
echo "--> link access Dashboard admin : "
echo "http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"

echo "---> Get token for Dashboard admin"
kubectl create serviceaccount dashboard -n default
kubectl create clusterrolebinding dashboard-admin -n default 
  --clusterrole=cluster-admin 
  --serviceaccount=default:dashboard

echo "--> will give you the token required for your dashboard login"
kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode  


echo "[TASK 8 --------install NFS--------]"

figlet NFS
apt-get install -y nfs-kernel-server
apt-get install -y nfs-common

mkdir -p /mnt/storage
cat >>/etc/hosts<<EOF
/mnt/storage *(rw,sync,no_root_squash,no_subtree_check)
EOF
systemctl restart nfs-kernel-server
exportfs -a

echo "------End Install  prerequisites\install.sh -----------"