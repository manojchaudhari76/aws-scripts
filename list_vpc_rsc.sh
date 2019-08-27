#!/bin/bash
# Created : Manoj CHAUDHARI
# Date : 25/08/2019
# Purpose : To list VPCs, Instances, InstanceType, Launch Time, Volumes, VolumeTypes etc
#
#

profile=$1
ec2Comm="aws ec2 --profile ${profile} "

for vpc in $(${ec2Comm} describe-vpcs |grep "VpcId" |awk -F ":" '{print $2}' |tr -d [\",])
do
dt=$(date +%m%d%y)
vpcInfo=account-${vpc}.info.list.${dt}
echo "Date|VPC|InstanceID|LaunchTime|InstanceType|VolumeIds|VolumeType|Iops|Size|AZ" > ${vpcInfo}

	for instance in $(${ec2Comm} describe-instances --filters "Name=vpc-id,Values=${vpc}" --query "Reservations[*].Instances[*].[InstanceId]" |tr -d [\[,\]\"] | awk 'NF > 0')
	do

	iLT=$(${ec2Comm} describe-instances --filters "Name=instance-id,Values=${instance}" --query "Reservations[*].Instances[*].[LaunchTime]" |tr -d [\[,\]\"] | awk 'NF > 0')
	
	iType=$(${ec2Comm} describe-instances --filters "Name=instance-id,Values=${instance}" --query "Reservations[*].Instances[*].[InstanceType]" |tr -d [\[,\]\"] | awk 'NF > 0')
	
	
		#echo "Volumes:" $(${ec2Comm} describe-instances --filters "Name=instance-id,Values=${instance}" --query "Reservations[*].Instances[*].[BlockDeviceMappings[*].Ebs.VolumeId]" |tr -d [\[,\]] | awk 'NF > 0') >> ${instVolInfo}
	
		for vol in $(${ec2Comm} describe-instances --filters "Name=instance-id,Values=${instance}" --query "Reservations[*].Instances[*].[BlockDeviceMappings[*].Ebs.VolumeId]" |tr -d [\[,\]\"] | awk 'NF > 0')
		do
		
		vType=$(${ec2Comm} describe-volumes --volume-id ${vol} --query 	"Volumes[*].[VolumeType]" |tr -d [\[,\]\"] | awk 'NF > 0')
		vIops=$(${ec2Comm} describe-volumes --volume-id ${vol} --query 	"Volumes[*].[Iops]" |tr -d [\[,\]\"] | awk 'NF > 0')
		vSize=$(${ec2Comm} describe-volumes --volume-id ${vol} --query 	"Volumes[*].[Size]" |tr -d [\[,\]\"] | awk 'NF > 0')
		vAZ=$(${ec2Comm} describe-volumes --volume-id ${vol} --query 	"Volumes[*].[AvailabilityZone]" |tr -d [\[,\]\"] | awk 'NF > 0')
		
		echo "${dt}|${vpc}|${instance}|${iLT}|${iType}|${vol}|${vType}|${vIops}|${vSize}|${vAZ}|" >> ${vpcInfo} 	
		
		done
		
	done
echo VPC: ${vpc}
echo -----------------------------------------------------
cat ${vpcInfo}  | tr -d " " >> vpcs.consolidated.info
echo -----------------------------------------------------
done; 



##aws ec2 describe-instances --filters "Name=vpc-id,Values=vpc-df0e2fb7" --profile ${profile} --query "Reservations[*].Instances[*].[InstanceId,ImageId,LaunchTime,InstanceType,BlockDeviceMappings[*].Ebs.VolumeId]"
#
#aws ec2 describe-instances --filters "Name=vpc-id,Values=vpc-df0e2fb7" --profile ${profile} --query "Reservations[*].Instances[*].[InstanceId]" |tr -d [\[,\]] | awk 'NF > 0'
#
#
#Find StartTime
#aws ec2 describe-instances --filters "Name=instance-id,Values=i-0f3064aac7777a8a9" --profile ${profile} --query "Reservations[*].Instances[*].[LaunchTime]" |tr -d [\[,\]] | awk 'NF > 0' 
#
#Find InstanceType
#aws ec2 describe-instances --filters "Name=instance-id,Values=i-0f3064aac7777a8a9" --profile ${profile} --query "Reservations[*].Instances[*].[InstanceType]" |tr -d [\[,\]] | awk 'NF > 0'
#
#Find Volumes
#aws ec2 describe-instances --filters "Name=instance-id,Values=i-0f3064aac7777a8a9" --profile ${profile} --query "Reservations[*].Instances[*].[BlockDeviceMappings[*].Ebs.VolumeId]" |tr -d [\[,\]] | awk 'NF > 0'
#
#aws ec2 describe-volumes --volume-id vol-0872c2dd50d006bb5 --profile ${profile} --query "Volumes[*].[VolumeType]" |tr -d [\[,\]] | awk 'NF > 0'
#aws ec2 describe-volumes --volume-id vol-0872c2dd50d006bb5 --profile ${profile} --query 	"Volumes[*].[Iops]" |tr -d [\[,\]] | awk 'NF > 0'
#aws ec2 describe-volumes --volume-id vol-0872c2dd50d006bb5 --profile ${profile} --query 	"Volumes[*].[Size]" |tr -d [\[,\]] | awk 'NF > 0' 
#aws ec2 describe-volumes --volume-id vol-0872c2dd50d006bb5 --profile ${profile} --query 	"Volumes[*].[AvailabilityZone]" |tr -d [\[,\]] | awk 'NF > 0'


