#!/bin/bash
#Author: twitter-handle: @rangapv
#        email-id: rangapv@yahoo.com
echo ""
echo "`clear`"
echo -e "THis is to inform \"kubernetes-cluster-status\" in this box " | cowsay -W95 -f default
echo ""
counter=0
status1=0
component(){
args1="$@"
pargs="$#"

retr=$(ps -ef |grep $args1 | awk '{ split($0,a," ") ; print a[8] }' | grep -v grep | grep $args1 | wc -l)
if [[ (( $retr=>1 )) ]]
then
   echo "\"$args1\" is running on this Box"
   ((counter+=1))
   status1=1
fi
}


master=$(ps -ef | grep kube | grep -v grep | wc -l)

if (( $master > 5 )) 
then
mastera=( kubelet kube-apiserver kube-controller-manager kube-scheduler etcd kube-proxy flanneld dashboard dockerd containerd )
declare -A arr
for i in "${mastera[@]}" 
do
	component $i
	arr[$i]=$status1
	status1=0
done
for h in "${mastera[@]}"
do
	args=arr[$@]
	args2=arr[$#]
	int1=0
done

masterb=( kubelet dockerd containerd)
for n in ${masterb[@]}
do
for h in "${mastera[@]}"
do
if [[ ( ${h} = "$n" ) && ( ${arr[$h]} -eq 1 ) ]] 
then
        echo ""
	echo "$h is installed in `which $h`"
	echo "$h version is `$h --version`"
 	echo ""
fi	   
done
done
	echo ""
echo "There are a total \"$counter\" components of k8s running on this Box"
if (( $counter >= 5 )) 
then
  echo "" 
  masterc=( kubelet kube-scheduler kube-controller-manager )
  for m in ${masterc[@]}
  do
      echo "$m is using `ps -ef | grep $m | grep "\-\-kubeconfig" | awk '{split($0,a,"--kubeconfig="); print a[2]}' | awk '{split($0,a," "); print a[1]}'`"
  done

  echo ""
  masterd=( kubelet )
  for m in ${masterd[@]}
  do
	  rnc=`ps -ef | grep "\-\-container-\runtime\-endpoint" | grep -v grep | wc -l`
	  if [[ $rnc=0 ]]
	  then
		  echo "This box is using runtime as Docker"
          else
                  echo "This box is using runtime as  `ps -ef | grep $m | grep "\-\-container-\runtime\-endpoint" | awk '{split($0,a,"--container-runtime-endpoint="); print a[2]}' | awk '{split($0,a," "); print a[1]}'`"
          fi
  done
  echo ""
  echo ""
  echo "Looks like this is the Master Node !!"
  echo ""
fi

elif [[ (( $master < 5 )) && (( $master > 1 )) ]] 
then
nodea=( kubelet kube-proxy flanneld dashboard dockerd containerd )
declare -A arrb
for j in "${nodea[@]}" 
do
	component $j
	arrb[$j]=$status1
	status1=0
done

nodeb=( kubelet dockerd containerd )
for k in ${nodeb[@]}
do
for l in "${nodea[@]}"
do
if [[ ( ${l} = "$k" ) && ( ${arrb[$l]} -eq 1 ) ]]
then
	echo ""
	echo "$l is installed in `which $l`"
	echo "$l version is `$l --version`"
	echo ""
fi
done
done
echo "There are a total \"$counter\" components of k8s running on this Box"
if (( $counter >= 3 )) 
then
   echo ""
   nodec=( kubelet )
   for v in ${nodec[@]}
   do
#	echo "$v is using `ps -ef | grep $v | grep "\-\-kubeconfig" | awk '{split($0,a,"--kubeconfig"); print a[2]}' | awk '{split($0,a," "); print a[1]}'`"
	echo "$v is using `ps -ef |grep $v | grep "\-\-kubeconfig" |  awk '{split($0,a,"--kubeconfig"); print a[2]}' | awk '{split($0,a," "); print a[1] " and the Cluster-DNS is " a[3]}'`"
  done
  echo ""
  noded=( kubelet )
  for v in ${noded[@]}
  do
	  rnc=`ps -ef | grep "\-\-container-\runtime\-endpoint" | grep -v grep | wc -l`
	  if [[ $rnc=0 ]]
	  then
		  echo "This box is using runtime as Docker"
          else
                  echo "This box is using runtime as  `ps -ef | grep $m | grep "\-\-container-\runtime\-endpoint" | awk '{split($0,a,"--container-runtime-endpoint="); print a[2]}' | awk '{split($0,a," "); print a[1]}'`"
          fi
  done
  echo ""
  echo "Looks like this is the Worker Node !!"
  echo ""
fi

else
  echo ""
  echo "There are very few components related to kubernetes running on this Box"
  echo " - hint k8s is NOT-INSTALLED on this Box - "
  echo ""
fi
