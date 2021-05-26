#!/bin/bash
echo "THis is to inform the kubernetes cluster status in this box"

component(){
args1="$@"
pargs="$#"


retr=$(ps -ef | grep $args1 | grep -v grep | wc -l)
if [[ ( $retr = 1 ) ]]
then
   echo "\"$args1\" is running on this Box"
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

