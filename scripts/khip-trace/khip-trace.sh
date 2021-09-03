#!/bin/bash

#set -x

rem_host=$1
if [ -z $rem_host ]
    then
    echo "usage: sudo bash ./khip_trace.sh <remote host>"
    exit 1
fi

active_nodes=`kubectl get nodes | grep Ready | grep -v master | awk '{print $1}'`

conn_data=()

for node in $active_nodes
    do
        tmp_data=```pdsh -w $node "conntrack -L -d $rem_host" 2> /dev/null | sed 's/use=./BRK/g'```
        dlm="BRK"
        x=$tmp_data$dlm
         while [[ $x ]]; 
            do
                conn_data+=( "${x%%"$dlm"*}" );
                x=${x#*"$dlm"};
            done
    done

conn_list=()
for con in "${conn_data[@]}"
    do 
        con_info=`echo "${con[@]}"`
        conn_typ=`echo $con_info | awk '{print $2;}'`
        conn_type='"'`echo $con_info | awk '{print $2;}'`'"'
        if [ "$conn_typ" = "tcp" ]
            then
                con_host='"'`echo $con_info | awk '{print $1;}' | sed s/://g`'"'
                con_sip='"'`echo $con_info | awk '{print $6;}' | sed s/src=//g`'"'
                con_sip_raw=`echo $con_info | awk '{print $6;}' | sed s/src=//g`
                con_pod='"'`kubectl get pods -A -o wide | grep -w $con_sip_raw  | awk '{print $2;}'`'"'
                con_ns='"'`kubectl get pods -A -o wide | grep -w $con_sip_raw  | awk '{print $1;}'`'"'
                con_sport='"'`echo $con_info | awk '{print $8;}' | sed s/sport=//g`'"'
                con_dip='"'`echo $con_info | awk '{print $7;}' | sed s/dst=//g`'"'
                con_dport='"'`echo $con_info | awk '{print $9;}' | sed s/dport=//g`'"'
                con_gw_ip='"'`echo $con_info | awk '{print $11;}' | sed s/dst=//g`'"'
                con_gw_port='"'`echo $con_info | awk '{print $13;}' | sed s/dport=//g`'"'
                host_data='{"host": {"name": '"$con_pod"', "namespace": '"$con_ns"', "type": '"$conn_type"', "node": '"$con_host"', "s_ip": '"$con_sip"', "s_port": '"$con_sport"', "d_ip": '"$con_dip"', "d_port": '"$con_dport"', "gw_ip": '"$con_gw_ip"', "gw_port": '"$con_gw_port"'}}'
                conn_list+="$host_data"
        elif [ "$conn_typ" = "udp" ]
            then
                con_host='"'`echo $con_info | awk '{print $1;}' | sed s/://g`'"'
                con_sip='"'`echo $con_info | awk '{print $5;}' | sed s/src=//g`'"'
                con_sip_raw=`echo $con_info | awk '{print $5;}' | sed s/src=//g`
                con_pod='"'`kubectl get pods -A -o wide | grep -w $con_sip_raw  | awk '{print $2;}'`'"'
                con_ns='"'`kubectl get pods -A -o wide | grep -w $con_sip_raw  | awk '{print $1;}'`'"'
                con_sport='"'`echo $con_info | awk '{print $7;}' | sed s/sport=//g`'"'
                con_dip='"'`echo $con_info | awk '{print $6;}' | sed s/dst=//g`'"'
                con_dport='"'`echo $con_info | awk '{print $8;}' | sed s/dport=//g`'"'
                con_gw_ip='"'`echo $con_info | awk '{print $11;}' | sed s/dst=//g`'"'
                con_gw_port='"'`echo $con_info | awk '{print $13;}' | sed s/dport=//g`'"'
                host_data='{"host": {"name": '"$con_pod"', "namespace": '"$con_ns"', "type": '"$conn_type"', "node": '"$con_host"', "s_ip": '"$con_sip"', "s_port": '"$con_sport"', "d_ip": '"$con_dip"', "d_port": '"$con_dport"', "gw_ip": '"$con_gw_ip"', "gw_port": '"$con_gw_port"'}}'
                conn_list+="$host_data"
        fi
    done

echo ""

jq -rn '["NODE","TYPE","SOURCE IP   ","PORT ","DESTINATION IP","PORT ","GATEWAY IP  ","PORT ","NAMESPACE   ","POD NAME"] as $fields |

(
  $fields,                        
  ($fields | map(length*"-")),
  (inputs | .[] | [.node, .type, .s_ip, .s_port, .d_ip, .d_port, .gw_ip, .gw_port, .namespace, .name])
) | @tsv' <<< ${conn_list[@]}


echo ""
