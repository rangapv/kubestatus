#!/bin/bash
echo "THis is to inform the kubernetes cluster status in this box"

component() {
args1="$@"
pargs="$#"
echo "args1 is $args1"
k1=$(ps -ef | grep "$@" | grep -v "grep")
k1s="$?"
echo "Inside component"
echo "k1s is $k1s"
if [[ ( $k1s = 0 ) ]]
then
  ret=0
else
  ret=1
fi
echo "ret is $ret"
}



component kube-scheduler
echo "klet1 is $klet1"
if [[ ( $ret = 0 ) ]]
then
  echo "componet function for kubelet worked"
fi

klet=$(ps -ef |grep kubelet)
klets="$?"
if [[( $klets = 0 ) ]]
then
  echo "kubelet is running"
fi
api=$(ps -ef |grep kube-apiserver)
apis="$?"
if [[( $apis = 0 ) ]]
then
  echo "kube-apiserver is running"
fi
kcontrol=$(ps -ef |grep kube-controller-manager)
kcontrols="$?"
if [[( $kcontrols = 0 ) ]]
then
  echo "kube-controller-manager is running"
fi
kschedule=$(ps -ef |grep kube-scheduler)
kschedules="$?"
if [[( $kschedules = 0 ) ]]
then
  echo "kube-scheduler is running"
fi
