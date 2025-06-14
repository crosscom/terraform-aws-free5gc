#!/bin/bash

# Set up kernel modules for GTP
cat > /etc/modules-load.d/gtp.conf << EOF
gtp
udp_tunnel
ip6_udp_tunnel
EOF

# Load kernel modules
modprobe gtp
modprobe udp_tunnel
modprobe ip6_udp_tunnel

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Get instance ID and AZ
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

# Create and attach network interfaces for Multus
%{ for network_name, subnet_id in multus_subnets ~}
# Create ENI for ${network_name} network
ENI_ID_${network_name}=$(aws ec2 create-network-interface \
  --subnet-id ${subnet_id} \
  --groups ${multus_sg_id} \
  --description "${cluster_name}-${node_group_name}-${network_name}" \
  --region ${region} \
  --tag-specifications 'ResourceType=network-interface,Tags=[{Key=Name,Value=${cluster_name}-${node_group_name}-${network_name}}]' \
  --query 'NetworkInterface.NetworkInterfaceId' \
  --output text)

# Attach ENI to the instance
aws ec2 attach-network-interface \
  --network-interface-id $ENI_ID_${network_name} \
  --instance-id $INSTANCE_ID \
  --device-index $((1 + ${index(keys(multus_subnets), network_name)})) \
  --region ${region}

%{ endfor ~}

# Bootstrap script for EKS
/etc/eks/bootstrap.sh ${cluster_name} --kubelet-extra-args "${kubelet_extra_args}"