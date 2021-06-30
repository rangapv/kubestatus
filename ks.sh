#!/bin/bash
#Author: twitter-handle: @rangapv
#        email-id: rangapv@yahoo.com
source <(curl -s https://raw.githubusercontent.com/rangapv/runtimes/main/checkruntime.sh)

echo ""
echo "`clear`"
echo -e "THis is to inform \"kubernetes-cluster-status\" in this box " | cowsay -W95 -f default
echo ""
counter=0
status1=0
nodef=0
declare -A arra

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

nodecomp() {
myarray=("$@")
for i in "${myarray[@]}" 
do
	component $i
	arra[$i]=$status1
	status1=0
done
}

myversion() {
declare -A arrb
verarray=("$@")
for n in ${verarray[@]}
do
for h in "${mastera[@]}"
do
if [[ ( ${h} = "$n" ) && ( ${arra[$h]} -eq 1 ) ]] 
then
        echo ""
	echo "$h is installed in `which $h`"
	echo "$h version is `$h --version`"
 	echo ""
fi	   
done
done
}

coreinstall() {
c="$@"
cc=0
cw=`which $c1`
cs= echo "$?"
for c in ${c[@]}
do
if [[ $cs -eq 0 ]]
then
	echo "This $c core component is just installed and not running"
	((cc+=1))
fi
done
}

myconfig() {
  arrayc=("$@")
  if [[ ( $nodef = 0 ) ]]
  then
  for m in ${arrayc[@]}
  do
      echo "$m is using `ps -ef | grep $m | grep "\-\-kubeconfig" | awk '{split($0,a,"--kubeconfig="); print a[2]}' | awk '{split($0,a," "); print a[1]}'`"
  done
  else
  for m in ${arrayc[@]}
  do
  echo "$m is using `ps -ef | grep $m | grep -v grep | grep -v awk | awk '{split($0,a," ");} a[8] ~ /sudo/ {print $11}'`"
  done
  fi
}

myruntime() {
  arrayr=("$@")

  for m in ${arrayr[@]}
  do
	  rnc=`ps -ef | grep "\-\-container-\runtime\-endpoint" | grep -v grep | wc -l`
	  if [[ ( $rnc = 0 ) ]]
	  then
		  echo "This box is using runtime as Docker"
          else
                  echo "This box is using runtime as  `ps -ef | grep $m | grep "\-\-container-\runtime\-endpoint" | awk '{split($0,a,"--container-runtime-endpoint="); print a[2]}' | awk '{split($0,a," "); print a[1]}'`"
          fi
  done

}

myrunc(){
if [[ $drun -eq 1 ]]
then
	echo "This box is using \"Dockerd\" as the runtime"
elif [[ $crun -eq 1 ]]
then
	echo "This box is using \"COntainerd\" as the runtime"
fi

}


master=$(ps -ef | grep kube | grep -v grep | wc -l)
if (( $master > 5 )) 
then
mastera=( kubelet kube-apiserver kube-controller-manager kube-scheduler etcd kube-proxy flanneld dashboard dockerd containerd )
nodecomp "${mastera[@]}"
declare -A arr
masterb=( kubelet dockerd containerd)
myversion "${masterb[@]}"

echo ""
echo "There are a total \"$counter\" components of k8s on this Box"
if (( $counter >= 5 )) 
then
  echo "" 
  masterc=( kubelet kube-scheduler kube-controller-manager )
  myconfig "${masterc[@]}" 
  echo ""
  masterd=( kubelet )
#  myruntime "${masterd[@]}" 
  myrunc
  echo ""
  echo ""
  echo "Looks like this is the Master Node !!"
  echo ""
fi

elif [[ (( $master < 5 )) && (( $master > 1 )) ]] 
then
nodef=1
mastera=( kubelet kube-proxy flanneld dashboard dockerd containerd )
nodecomp "${mastera[@]}"
declare -A arrb
nodeb=( kubelet dockerd containerd )
myversion "${nodeb[@]}"
echo ""
echo "There are a total \"$counter\" components of k8s running on this Box"
if (( $counter >= 3 )) 
then
   echo ""
   nodec=( kubelet )
   myconfig "${nodec[@]}"
	#echo "$v is using `ps -ef |grep $v | grep "\-\-kubeconfig" |  awk '{split($0,a,"--kubeconfig"); print a[2]}' | awk '{split($0,a," "); print a[1] " and the Cluster-DNS is " a[3]}'`"
  echo ""
  noded=( kubelet )
#  myruntime "${noded[@]}"
  myrunc
  echo ""
  echo "Looks like this is the Worker Node !!"
  echo ""
fi

elif [[ (( $master -eq 0 )) ]]
then
core1=( kubeadm kubelet kubectl )
coreinstall "${core1[@]}"
if (( $cc > 0 ))
then
	echo "The total core componet of k8s that are installed but not running is $cc"
elif (( $cc -eq 0 ))
then
  echo "There are very few components related to kubernetes running on this Box"
  echo " - hint k8s is NOT-INSTALLED on this Box - "
fi

else
  echo ""
  echo ""
fi
