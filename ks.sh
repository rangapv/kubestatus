#!/bin/bash
#Author: twitter-handle: @rangapv
#        email-id: rangapv@yahoo.com
source <(curl -s https://raw.githubusercontent.com/rangapv/runtimes/main/checkruntime.sh)

echo "`clear`"
echo -e "This is to inform \"kubernetes-cluster-status\" in this box " | cowsay -W95 -f default
echo ""
counter=0
corecounter=0
status1=0
nodef=0
declare -A arra

component() {
echo ""
args1="$@"
pargs="$#"
myarray=("$@")
for i in "${myarray[@]}" 
do
     retr=$(ps -ef |grep $i | awk '{ split($0,a," ") ; print a[8] }' | grep -v grep | grep $i | wc -l)
     if [[ (( $retr -ge 1 )) ]]
     then
     ((counter+=1))
     ((corecounter+=1))
     status1=1
     fi
     arra[$i]=$status1
     status1=0
done
echo ""
}

compstat() {
p=("$@")
str1=""
str4=""
sflag=1
nglag=1
for k in "${p[@]}"
do
	 if [[ ${arra[$k]} -eq 1 ]]
	 then
               str1+="$k,"
	       sflag=0
        else
	       str4+="$k,"
	       nflag=0 
	 fi
done
if [[ ( $sflag -eq 0) ]]
then
	myprint1 Running-Components
echo ""
echo "$str1" |  awk '{split($0,a,","); for (i=1;i<length(a);i=i+2) print a[i] "," a[i+1]; print "Total = " length(a)-1 }'
elif [[ ( $nflag -eq 0) ]]
then
	myprint1 Not-running-Components
echo "All these components are NOT installed"
echo ""
echo "$str1" |  awk '{split($0,a,","); for (i=1;i<length(a);i=i+2) print a[i] "," a[i+1]; print "Total = " length(a)-1 }'
fi
}

mycni() {
cni=("$@")
myprint1 Cluster-CNI
for c in "${cni[@]}"
do
c1=`ps -ef | grep $c | grep -v grep | wc -l`
	if [[ ( $c1 -gt 0 ) ]]
	then
		echo "$c is up and running"
	fi

done

}

myversion() {
echo ""
declare -A arrb
verarray=("$@")
myprint1 Component-Version
#myprint1 $h
awk -F: 'BEGIN{printf "%-10s %-25s %-50s \n", "Component   ", "Install-Path", "Version-Info"
               printf "%-10s %-25s %-50s \n", "------------", "------------", "------------"}'
for n in ${verarray[@]}
do
for h in "${mastera[@]}"
do
if [[ ( ${h} = "$n" ) && ( ${arra[$h]} -eq 1 ) ]] 
then
#	echo "$h is installed in `which $h`"
#	echo "$h version is `$h --version`"
        whch=`which $h`
	whv=`$h --version`
        awk -F: -v h2="$h" -v h1="$whch" -v whv="$whv" 'BEGIN{printf "%-10s %-25s %-50s \n" , h2, h1, whv}'

fi	   
done
done
echo ""
}

coreinstall() {
c=("$@")
cc=0
echo ""
for cd in ${c[@]}
do
cw=$(which $cd)
cs="$?"
if [[ (( $cs -eq 0 )) ]]
then
	awk -v a="$cd" -v b="$cw" 'BEGIN{ printf "%-12s %-15s \n",a, b}'
	((cc+=1))
else
	echo "This $cd core component is not installed"
fi
done
if [[ (( $cc -eq 0 )) ]]
then
	myprint1 Core-Components-Missing
  echo "None of the core components \"${c[@]}\" are installed "
fi
echo ""
}

myconfig() {
echo ""
  myprint1 Core-Component-Configfiles
  arrayc=("$@")
  awk -F: 'BEGIN{printf "%-10s %-25s \n","----------","-----------"
                 printf "%-10s %-25s \n","Component","Config-file"
	         printf "%-10s %-25s \n" ,"----------","-----------"}' 
  if [[ ( $nodef = 0 ) ]]
  then
  for m in ${arrayc[@]}
  do
	  compconfig=(`ps -ef | grep $m | grep "\-\-kubeconfig" | awk '{split($0,a,"--kubeconfig="); print a[2]}' | awk '{split($0,a," "); print a[1]}'`)
         awk -F: -v config="$compconfig" -v m1="$m" 'BEGIN{ printf "%-10s %-25s \n", m1, config }' 
  done
  else
  for m in ${arrayc[@]}
  do
#  echo "$m is using `ps -ef | grep $m | grep -v grep | grep -v awk | awk '{split($0,a," "); a[8] ~ /kubelet/; print a[10]}' | awk '{split($0,a,"--kubeconfig="); print a[2]}'`"
compconfig=(`ps -ef | grep $m | grep -v grep | grep -v awk | awk '{split($0,a," "); if (a[8]~/kubelet/) for (i=0;i<14;i++) if (a[i]~/--kubeconfig/) print a[i]  a[i+1]}'`)
  #echo "$m is using `ps -ef | grep $m | grep -v grep | grep -v awk | awk '{split($0,a," "); a[8] ~ /kubelet/; print a[11]}' | awk '{split($0,a,"--kubeconfig="); print a[2]}'`"
         awk -F: -v config="$compconfig" -v m1="$m" 'BEGIN{ printf "%-10s %-25s \n", m1, config }' 
  done
  fi
echo ""
}

myrunc(){
  myprint1 Container-Runtime
if [[ $drun -eq 1 ]]
then
	echo "This box is using \"Dockerd\" as the runtime"
        if [[ (( $dnrun -eq 1 )) ]]
	then
		echo "But it is NOT-running"
	fi
elif [[ $crun -eq 1 ]]
then
	echo "This box is using \"Containerd\" as the runtime"
        if [[ (( $cnrun -eq 1 )) ]]
	then
		echo "But it is NOT-running"
	fi
else
	echo "No suitable runtime for container available"
fi

}

myprint1() {
cl2="$@"
awk -F: -v c2="$cl2" 'BEGIN{printf "%-12s \n","-------------------"
                            printf "%-12s \n",c2
			    printf "%-12s \n", "-----------------"}'
}


myprint() {
cl1="$@"
awk -F: -v c1="$cl1" 'BEGIN{printf "%-12s %-15s \n","--------","------------"
                printf "%-12s %-15s \n","Process","Install Path"
                printf "%-12s %-15s \n","-------","-------------"}' 
	}

coreprint() {
  if [[ $cc -lt 3 ]]
  then
	  echo "The total core component of k8s that are not installed is $(( 3-$cc ))"
  elif [[ $cc -eq 3 ]]
  then
	echo "All the core components (\"${core1[@]}\") of k8s are installed"
  fi
}

core1=( kubeadm kubelet kubectl )
cnil=( calico flannel )
myprint1 Core-Statistics 
myprint
coreinstall "${core1[@]}"
myprint1 Runtime
myrunc
#mastera=( kubelet kube-apiserver kube-controller-manager kube-scheduler etcd )
#myprint1 Component-Statistics 
#component "${mastera[@]}"

master=$(ps -ef | grep kube | grep -v grep | grep -v vi | wc -l)

if [[ (( $cc -eq 3 )) ]]
then
 #mastera=( kubelet kube-apiserver kube-controller-manager kube-scheduler etcd )
 mastera=( kubelet kube-apiserver kube-controller-manager kube-scheduler etcd kube-proxy flanneld dashboard dockerd containerd )
 myprint1 Component-Statistics 
 component "${mastera[@]}"
 compstat "${mastera[@]}"
 
 if [[ (( $corecounter -gt 6 )) ]]
 then
 declare -A arr
 masterb=( kubelet dockerd containerd)
 myversion "${masterb[@]}"
 if [[ (( $counter -ge 5 )) ]]
 then
  masterc=( kubelet kube-scheduler kube-controller-manager )
  myconfig "${masterc[@]}"
  mycni "${cnil[@]}" 
  myprint1 Node-Status
  coreprint
  echo "There are a total \"$counter\" components of k8s running on this Box"
  echo "Looks like this is the Master Node !!"
  echo ""
 fi

 elif [[ (( $corecounter -gt 0 )) && (( $corecounter -lt 6 )) ]] 
 then
 nodef=1
 declare -A arrb
 nodeb=( kubelet dockerd containerd )
 myversion "${nodeb[@]}"
 if [[ (( $counter -ge 2 )) ]]
 then
  nodec=( kubelet )
  myconfig "${nodec[@]}"
  mycni "${cnil[@]}" 
  myprint1 Node-Status
  coreprint
  echo "There are a total \"$counter\" components of k8s running on this Box"
  echo "Looks like this is the Worker Node !!"
  echo ""
 fi
 fi
else
#if [[ (( $corecounter -eq 0 )) && (( $master -eq 0 )) ]]
#then
  myprint1 Node-Status
  coreprint
  echo "There are very few components related to kubernetes running on this Box"
  echo " - hint k8s is NOT-INSTALLED on this Box - "
fi
