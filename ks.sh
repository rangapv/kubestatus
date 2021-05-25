#!/bin/bash
echo "THis is to inform the kubernetes cluster status in this box"
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
