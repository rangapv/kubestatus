#!/bin/bash
#Author: twitter-handle: @rangapv
#        email-id: rangapv@yahoo.com
source <(curl -s https://raw.githubusercontent.com/rangapv/runtimes/main/checkruntime.sh)

echo "`clear`"
echo -e "THis is to inform \"kubernetes-cluster-status\" in this box " | cowsay -W95 -f default
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
     if [[ (( $retr=>1 )) ]]
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
	myprint1 Installed-Components
echo "All these components ${str1::-1} are installed"
elif [[ ( $nflag -eq 0) ]]
then
	myprint1 Missing-Components
echo "All these components ${str4::-1} are NOT installed"
fi
}

myversion() {
echo ""
declare -A arrb
verarray=("$@")
myprint1 Component-Version
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
	myprint1 $h
        awk -F: 'BEGIN{printf "%-10s %25s \n", "Install-Path", "Version-Info"
                       printf "%-10s %25s \n", "------------", "------------"}'
        awk -F: -v h1="$whch" -v whv="$whv" 'BEGIN{printf "%-10s %25s \n" , h1,  whv}'

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
if [[ $cs -eq 0 ]]
then
	awk -v a="$cd" -v b="$cw" 'BEGIN{ printf "%-12s %-15s \n",a, b}'
	((cc+=1))
else
echo "This $cd core component is not installed" 
fi
done
if [[ $cc -eq 0 ]]
then
	myprint1 Core-Components-Missing
  echo "None of the core components \"${c[@]}\" are installed "
fi
echo ""
}

myconfig() {
echo ""
  myprint1 Core-Components-Configfiles
  arrayc=("$@")
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

myruntime() {
  arrayr=("$@")
echo ""
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
echo ""

}

myrunc(){
  myprint1 Container-Runtime
if [[ $drun -eq 1 ]]
then
	echo "This box is using \"Dockerd\" as the runtime"
elif [[ $crun -eq 1 ]]
then
	echo "This box is using \"Containerd\" as the runtime"
fi

echo ""
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



core1=( kubeadm kubelet kubectl )
myprint1 Core-Statistics 
myprint
coreinstall "${core1[@]}"


mastera=( kubelet kube-apiserver kube-controller-manager kube-scheduler etcd )
myprint1 Component-Statistics 
component "${mastera[@]}"

master=$(ps -ef | grep kube | grep -v grep | wc -l)

if [[ (( $corecounter -gt 1 )) ]]
then
if [[ $cc -lt 3 ]]
then
	echo "The total core components of k8s that are not running is $cc"
elif [[ $cc -eq 3 ]]
then
	echo "All the core components (\"${core1[@]}\") of k8s are installed"
fi
mastera=( kubelet kube-apiserver kube-controller-manager kube-scheduler etcd kube-proxy flanneld dashboard dockerd containerd )
component "${mastera[@]}"
compstat "${mastera[@]}"

declare -A arr
masterb=( kubelet dockerd containerd)
myversion "${masterb[@]}"

echo "There are a total \"$counter\" components of k8s on this Box"
if (( $counter >= 5 )) 
then
  masterc=( kubelet kube-scheduler kube-controller-manager )
  myconfig "${masterc[@]}" 
  masterd=( kubelet )
#  myruntime "${masterd[@]}" 
  myrunc
  echo "Looks like this is the Master Node !!"
  echo ""
fi

elif [[ (( $corecounter -le 1 )) && (( $master -gt 0 )) ]] 
then
if [[ $cc -lt 3 ]]
then
	echo "The total core component of k8s that are not running is $cc"
elif [[ $cc -eq 3 ]]
then
	echo "All the core components (\"${core1[@]}\") of k8s are installed"
fi
nodef=1
mastera=( kubelet kube-proxy flanneld dashboard dockerd containerd )
component "${mastera[@]}"
compstat "${mastera[@]}"
declare -A arrb
nodeb=( kubelet dockerd containerd )
myversion "${nodeb[@]}"
echo ""
echo "There are a total \"$counter\" components of k8s running on this Box"
if (( $counter >= 3 )) 
then
   nodec=( kubelet )
   myconfig "${nodec[@]}"
	#echo "$v is using `ps -ef |grep $v | grep "\-\-kubeconfig" |  awk '{split($0,a,"--kubeconfig"); print a[2]}' | awk '{split($0,a," "); print a[1] " and the Cluster-DNS is " a[3]}'`"
  noded=( kubelet )
#  myruntime "${noded[@]}"
  myrunc
  echo "Looks like this is the Worker Node !!"
  echo ""
fi

elif [[ (( $master -eq 0 )) ]]
then
if [[ $cc > 0 ]]
then
	echo "The total core componet of k8s that are not running is $cc"
else  
  echo "There are very few components related to kubernetes running on this Box"
  echo " - hint k8s is NOT-INSTALLED on this Box - "
fi

else
  echo ""
  echo ""
fi
