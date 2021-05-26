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


master=$(ps -ef | grep kube | grep -v grep | wc -l)

if [[ $master > 5 ]]
then
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

elif [[ $master < 5 ]]
then
component /usr/bin/kubelet
component kube-proxy 
component flanneld 
component dashboard 

echo "There are a total \"$counter\" components of k8s running on this Box"
if [[ $counter > 3 ]]
then
  echo "Looks like this is the WOrker Node !!"
fi

else
  echo "There are very few componeents related to k8s runnign on this Box - hint k8s is not installed on this Box"
fi
