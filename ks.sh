#!/bin/bash
#Author: twitter-handle: @rangapv
#        email-id: rangapv@yahoo.com
echo ""
echo "THis is to inform \"kubernetes-cluster-status\" in this box"
echo ""
counter=0
component(){
args1="$@"
pargs="$#"

retr=$(ps -ef |grep $args1 | awk '{ split($0,a," ") ; print a[8] }' | grep -v grep | grep $args1 | wc -l)
if [[ ( $retr = 1 ) ]]
then
   echo "\"$args1\" is running on this Box"
   ((counter+=1))
fi
}


master=$(ps -ef | grep kube | grep -v grep | wc -l)

if (( $master > 5 )) 
then
mastera=( kubelet kube-apiserver kube-controller-manager kube-scheduler etcd kube-proxy flanneld dashboard dockerd )
for i in "${mastera[@]}" 
do
	component $i
done
	
echo ""
echo "There are a total \"$counter\" components of k8s running on this Box"
if (( $counter >= 5 )) 
then
  echo ""
  echo "Looks like this is the Master Node !!"
  echo ""
fi

elif [[ (( $master < 5 )) && (( $master > 1 )) ]] 
then
nodea=( kubelet kube-proxy flanneld dashboard dockerd )
for j in "${nodea[@]}" 
do
	component $j
done

echo "There are a total \"$counter\" components of k8s running on this Box"
if (( $counter >= 3 )) 
then
  echo ""
  echo "Looks like this is the WOrker Node !!"
  echo ""
fi

else
  echo ""
  echo "There are very few components related to kubernetes running on this Box"
  echo " - hint k8s is NOT-INSTALLED on this Box - "
  echo ""
fi
