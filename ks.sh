#!/bin/bash
echo "THis is to inform the kubernetes cluster status in this box"
counter=0
component(){
args1="$@"
pargs="$#"


retr=$(ps -ef | grep $args1 | grep -v grep | wc -l)
if [[ ( $retr = 1 ) ]]
then
   echo "\"$args1\" is running on this Box"
   ((counter+=1))
fi

}


component /usr/bin/kubelet
component kube-apiserver
component kube-controller-manager
component kube-scheduler
component etcd 
component kube-proxy 
component flanneld 
component dashboard 
component /usr/bin/dockerd

echo "There are a total \"$counter\" components of k8s running on this Box"
if [[ $counter > 6 ]]
then
  echo "Looks like this is the Master Node !!"
fi
