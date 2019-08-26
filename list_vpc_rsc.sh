#!/bin/bash
# Created : Manoj CHAUDHARI
# Date : 25/08/2019
# Purpose : To list VPCs, Instances, InstanceType, Launch Time, Volumes, VolumeTypes etc
#
#

profile=$1

aws ec2 describe-vpcs --profile ${profile} |grep "VpcId" |awk -F ":" '{print $2}' |tr -d [\",] >/tmp/vpc-ids.$$

for vpc in $(cat /tmp/vpc-ids.$$); do

echo VPC:${vpc}

aws ec2 describe-instances --filters "Name=vpc-id,Values=${vpc}" --profile ${profile} |grep InstanceId|awk -F \" '{print $4}' >/tmp/instance-ids.${vpc}.$$

cat /tmp/instance-ids.${vpc}.$$


done; 
