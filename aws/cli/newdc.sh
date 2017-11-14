#!/bin/bash
#byLeal Copyright(c) Mar/2014.
# ----------------------------------------------------------------------------
# ---=  AWS Workshop I (Webservices, SDK, Command Line, Network VPC/VPN)  =---
# ---=      Configuration on the New Datacenter (USA Region) Part 1       =---
# ----------------------------------------------------------------------------
# +--------------------------------------------------------------------------+
# |                           - README -                                     |
# | VPC Network/VPN Command Line Practice                                    |
# |     a) Create a VPC in a Second Region;                                  |
# |     b) Create two subnets in that VPC: one public and another private;   |
# |     c) Allocate an Elastic IP;                                           |
# |     d) Configure a Hardware VPN Connection at the FIRSTREGION: VCG, VPG  |
# |          and VPN;                                                        |
# |     e) Configure the routing table for the vpn;                          |
# |     f) Create and configure a GNU/Linux EC2 instance/Amazon Linux/VCG    |
# |          (Install Script/User Data);                                     |
# |     g) Create and configure the routing tables;                          |
# |     h) Create and configure a Windows 2003 instance at the SECONDREGION, |
# |           PRIVSUBNET, joining the AD Domain at the FIRSTREGION           |
# |           (Install Script/User Data);                                    |
# +--------------------------------------------------------------------------+

# ---> Global VARS <---
export KEYNAME="yourkeyname"
export LNXAMI="ami-13f9de56"
export WINAMI="ami-1a7d415f"
export ADDSIP="172.31.23.46"
export VPCSECCIDR="10.31.0.0/16"
export PUBSUBNET="10.31.0.0/24"
export PRIVSUBNET="10.31.1.0/24"
export VPCPRICIDR="172.31.0.0/16"
export FIRSTREGION="sa-east-1"
export SECONDREGION="us-west-1"
export ADDSDOMAIN="thinkbig.aroundcorners.com.br"
export ADMINUSER="${ADDSDOMAIN}\aroundcorners"
export ADMINPASSWD='agora%!teste2##'
export PUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDH2n8boA4AcqehlzF19/0uxShnKJnAh9NCBvswz/RNR6UtsJFCvjmBkcOyU/4faUDoxvaQ2yQRfV35Etr8wghPqF8vufEhLL8m6ycvk64OwhOwV5ii5oRiriVfheHkYxgdAKSbisbQAL7Dl+QFrco+TIYZkMyHUPU5BuWUIFTUUqQaD+gwIcSgsipJkQRvU1rtlufGzBYMw0A8+M93ucxpeAxFHYsWg2MsfqJ5A1XcxASJcV2Aj8yYxKb8REAr1h83xFa68bkwfXuQ/HL73cduBfoNcUCeb2pf+YJC/muFsWfdmod4zr19lhdOQkQIM/VYaDrGXGtvLYxoQsgBdHMT msleal"
export TMPDIR=/tmp/
# >> ----------------------------------------------------------------- <<
# >> You should not need to change anything else starting from here... <<
# >> but, you know... I can be wrong.                                  <<
# >> ----------------------------------------------------------------- <<

# Game on!
# >>> PROCEDURE EXECUTED IN THE SECONDREGION (Part #1)
export REGION="$SECONDREGION"; export AWS_DEFAULT_REGION="$SECONDREGION"
### a) Create the VPC at SECONDREGION
aws ec2 create-vpc --cidr-block $VPCSECCIDR >/dev/null 2>&1 && echo "01/35 >>> [$SECONDREGION] VPC Created OK"
echo -n "-> Waiting to get the ID for the resource(s) created."
while [[ -z "$VPCID" ]]; do
        export VPCID=`aws ec2 describe-vpcs --filters "Name=cidr-block,Values=$VPCSECCIDR" --query Vpcs[*].VpcId --output text`
        echo -n "."
done
echo " Got it! Moving on..."
### b) Create two subnets in that VPC: one public and another private;
aws ec2 create-subnet --vpc-id $VPCID --cidr-block $PUBSUBNET >/dev/null 2>&1 && echo "02/35 >>> [$SECONDREGION] SUBNET: $PUBSUBNET Created OK"
aws ec2 create-subnet --vpc-id $VPCID --cidr-block $PRIVSUBNET >/dev/null 2>&1 && echo "03/35 >>> [$SECONDREGION] SUBNET: $PRIVSUBNET Created OK"
# Create the private subnet routing table...
aws ec2 create-route-table --vpc-id $VPCID >/dev/null 2>&1 && echo "04/35 >>> [$SECONDREGION] Private Subnet Rounting Table Created OK"
echo -n "-> Waiting to get the ID for the resource(s) created."
while [[ -z "$PUBSUBNETID" ]] || [[ -z "$PRIVSUBNETID" ]] || [[ -z "$RTBID" ]] || [[ -z "$RTBID2" ]]; do
        export PUBSUBNETID=`aws ec2 describe-subnets --filters "Name=cidr-block,Values=$PUBSUBNET" --query Subnets[*].SubnetId --output text`
        export PRIVSUBNETID=`aws ec2 describe-subnets --filters "Name=cidr-block,Values=$PRIVSUBNET" --query Subnets[*].SubnetId --output text`
        export RTBID=`aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPCID" "Name=association.main,Values=true" --output text --query RouteTables[*].RouteTableId`
        for x in `aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPCID"  --output text --query RouteTables[*].RouteTableId | grep "$RTBID"`; do if [ $x != $RTBID ]; then export RTBID2="$x"; fi; done
        echo -n "."
done
echo " Got it! Moving on..."
aws ec2 associate-route-table --subnet-id $PRIVSUBNETID --route-table-id $RTBID2 >/dev/null 2>&1 && echo "05/35 >>> [$SECONDREGION] Private Rounting Table Associated OK"
### c) Allocate an Elastic IP;
aws ec2 allocate-address --domain vpc >/dev/null 2>&1 && echo "06/35 >>> [$SECONDREGION] Elastic IP Allocated OK"
# Create the internet gateway and associate with the VPC
aws ec2 create-internet-gateway >/dev/null 2>&1 && echo "07/35 >>> [$SECONDREGION] Internet Gateway Created OK"
# Create/Configure SSH/VPN Security Group for the GNU/Linux and upload the credentials (pub key)
aws ec2 create-security-group --group-name vpn --description "SSH and VPN Access" --vpc-id $VPCID >/dev/null 2>&1 && echo "08/35 >>> [$SECONDREGION] Security Group Created OK"
echo -n "-> Waiting to get the ID for the resource(s) created."
while [[ -z "$SGSSHID" ]] || [[ -z "$IGWID" ]] || [[ -z "$EIP" ]] || [[ -z "$EIPID" ]]; do
        export EIP=`aws ec2 describe-addresses --query Addresses[*].PublicIp --output text`
        export EIPID=`aws ec2 describe-addresses --query Addresses[*].AllocationId --output text`
        export IGWID=`aws ec2 describe-internet-gateways --query InternetGateways[*].InternetGatewayId --output text`
        export SGSSHID=`aws ec2 describe-security-groups --filters "Name=group-name,Values=vpn" --query SecurityGroups[*].GroupId --output text`
        echo -n "."
done
echo " Got it! Moving on..."
aws ec2 attach-internet-gateway --internet-gateway-id $IGWID --vpc-id $VPCID >/dev/null 2>&1 && echo "09/35 >>> [$SECONDREGION] Internet Gateway Attached OK"
aws ec2 create-route --route-table-id $RTBID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGWID >/dev/null 2>&1 && echo "10/35 >>> [$SECONDREGION] Route Created OK"
aws ec2 authorize-security-group-ingress --group-id $SGSSHID --protocol tcp --port 22 --cidr 0.0.0.0/0 >/dev/null 2>&1 && echo "11/35 >>> [$SECONDREGION] Firewall Rule Added OK"
aws ec2 authorize-security-group-ingress --group-id $SGSSHID --protocol -1 --port all --cidr $VPCSECCIDR >/dev/null 2>&1 && echo "12/35 >>> [$SECONDREGION] Firewall Rule Added OK"
aws ec2 authorize-security-group-ingress --group-id $SGSSHID --protocol -1 --port all --cidr $VPCPRICIDR >/dev/null 2>&1 && echo "13/35 >>> [$SECONDREGION] Firewall Rule Added OK"
aws ec2 import-key-pair --key-name $KEYNAME --public-key-material "$PUBKEY" >/dev/null 2>&1 && echo "14/35 >>> [$SECONDREGION] Public Key Uploaded OK"

# >>> PROCEDURE EXECUTED IN THE FIRSTREGION
export REGION="$FIRSTREGION"; export AWS_DEFAULT_REGION="$FIRSTREGION"
### d) Configure a Hardware VPN Connection at the FIRSTREGION: VCG, VPG
echo -n "-> Waiting to get the ID for the resource(s) created."
while [[ -z "$VPCID2" ]]; do
        export VPCID2=`aws ec2 describe-vpcs --filters "Name=cidr-block,Values=$VPCPRICIDR" --query Vpcs[*].VpcId --output text`
        echo -n "."
done
echo " Got it! Moving on..."
aws ec2 create-customer-gateway --type ipsec.1 --public-ip $EIP --bgp-asn 65534 >/dev/null 2>&1 && echo "15/35 >>> [$FIRSTREGION] Customer Gateway Created OK"
aws ec2 create-vpn-gateway --type ipsec.1 >/dev/null 2>&1 && echo "16/35 >>> [$FIRSTREGION] Virtual Private Gateway Created OK"
echo -n "-> Waiting to get the ID for the resource(s) created."
while [[ -z "$CGWID" ]] || [[ -z "$VGWID" ]]; do
        export CGWID=`aws ec2 describe-customer-gateways --filters "Name=bgp-asn,Values=65534" "Name=state,Values=available" --query CustomerGateways[*].CustomerGatewayId --output text`
        export VGWID=`aws ec2 describe-vpn-gateways --filters "Name=state,Values=available" --query VpnGateways[*].VpnGatewayId --output text`
        echo -n "."
done
echo " Got it! Moving on..."
aws ec2 attach-vpn-gateway --vpn-gateway-id $VGWID --vpc-id $VPCID2 >/dev/null 2>&1 && echo "17/35 >>> [$FIRSTREGION] Virtual Private Gateway Attached OK"
aws ec2 create-vpn-connection --type ipsec.1 --options StaticRoutesOnly=yes --customer-gateway-id $CGWID --vpn-gateway-id $VGWID >/dev/null 2>&1 && echo "18/35 >>> [$FIRSTREGION] VPN Created OK"
echo -n "-> Waiting to get the ID for the resource(s) created."
while [[ -z "$VPNID" ]] || [[ -z "$RTBID3" ]]; do
        export VPNID=`aws ec2 describe-vpn-connections --filters "Name=customer-gateway-id,Values=$CGWID" "Name=state,Values=available" --query VpnConnections[*].VpnConnectionId --output text`
        export RTBID3=`aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPCID2" --query RouteTables[*].RouteTableId --output text`
        echo -n "."
done
echo " Got it! Moving on..."
aws ec2 create-vpn-connection-route --vpn-connection-id $VPNID --destination-cidr-block $VPCSECCIDR >/dev/null 2>&1 && echo "19/35 >>> [$FIRSTREGION] VPN Route Created OK"
aws ec2 create-route --route-table-id $RTBID3 --destination-cidr-block $VPCSECCIDR --gateway-id $VGWID >/dev/null 2>&1 && echo "20/35 >>> [$FIRSTREGION] Route Added OK"
echo -n "-> Waiting to get the ID for the resource(s) created."
while [[ -z "$PSK" ]]; do
        export PSK=`aws ec2 describe-vpn-connections --filters "Name=customer-gateway-id,Values=$CGWID" --query VpnConnections[*].CustomerGatewayConfiguration --output text | grep -m1 "pre_shared" | sed -e 's,.*<pre_shared_key>\([^<]*\)</pre_shared_key>.*,\1,g'`
        echo -n "."
done
echo " Got it! Moving on..."
if [ `echo $PSK | wc -c` == 33 ]; then echo "21/35 >>> [$SECONDREGION] PreSharedKey Parsed OK"; else echo "ERROR: Parser of the PreSharedKey Failed."; exit 1; fi
echo -n "-> Waiting to get the ID for the resource(s) created."
while [[ -z "$RIGHTIP" ]]; do
        export RIGHTIP=`aws ec2 describe-vpn-connections --filters "Name=customer-gateway-id,Values=$CGWID" --query VpnConnections[*].CustomerGatewayConfiguration --output text | grep "ip_address" | grep -m 1 "177." | sed -e 's,.*<ip_address>\([^<]*\)</ip_address>.*,\1,g'`
        echo -n "."
done
echo " Got it! Moving on..."

# >>> PROCEDURE EXECUTED IN THE SECONDREGION (Part #2)
export REGION=$SECONDREGION; export AWS_DEFAULT_REGION=$SECONDREGION
# Add the VPN needed ports and protocols to the SSH/VPN Security Group...
aws ec2 authorize-security-group-ingress --group-id $SGSSHID --protocol udp --port 500 --cidr $RIGHTIP/32 >/dev/null 2>&1 && echo "22/35 >>> [$SECONDREGION] Firewall Rule Added OK"
aws ec2 authorize-security-group-ingress --group-id $SGSSHID --protocol udp --port 4500 --cidr $RIGHTIP/32 >/dev/null 2>&1 && echo "23/35 >>> [$SECONDREGION] Firewall Rule Added OK"
aws ec2 authorize-security-group-ingress --group-id $SGSSHID --protocol  50 --cidr $RIGHTIP/32 >/dev/null 2>&1 && echo "24/35 >>> [$SECONDREGION] Firewall Rule Added OK"
aws ec2 authorize-security-group-ingress --group-id $SGSSHID --protocol  51 --cidr $RIGHTIP/32 >/dev/null 2>&1 && echo "25/35 >>> [$SECONDREGION] Firewall Rule Added OK"
# aws ec2 describe-images --filters "Name=root-device-type,Values=ebs" "Name=architecture,Values=x86_64" "Name=owner-alias,Values=amazon" "Name=description,Values=Amazon Linux AMI*" --query Images[*].[ImageId,RootDeviceType,ImageOwnerAlias,Description]
### f) Create and configure a GNU/Linux EC2 instance/Amazon Linux/VCG (Install Script/User Data);
TMPSCRLNX=`mktemp`
cat <<EOF > $TMPSCRLNX
aws ec2 run-instances --image-id $LNXAMI  --instance-type m1.medium --count 1 --associate-public-ip-address --subnet-id $PUBSUBNETID --security-group-ids $SGSSHID --key-name $KEYNAME --user-data '#!/bin/bash
yum install -y openswan
yum install -y dash.x86_64
yum install -y diffutils
yum install -y lsof.x86_64
yum install -y traceroute.x86_64
echo "include /etc/ipsec.d/*.conf" >> /etc/ipsec.conf
echo "conn usatobr
     type=tunnel
     authby=secret
     left=%defaultroute
     leftid=$EIP
     right=$RIGHTIP
     leftsubnet=$VPCSECCIDR
     rightsubnet=$VPCPRICIDR
     pfs=yes
     auto=start
" > /etc/ipsec.d/usatobr.conf
echo "$EIP $RIGHTIP: PSK \"$PSK\"" > /etc/ipsec.d/usatobr.secrets
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.forwarding = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.eth0.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.lo.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.eth0.send_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.lo.send_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.conf
service network restart
chkconfig ipsec on
service ipsec start
echo "SSH and OpenSWAN VPN Server Installed OK"' || exit 2
exit 0
EOF
chmod 700 $TMPSCRLNX
$TMPSCRLNX >/dev/null 2>&1 && echo "26/35 >>> [$SECONDREGION] GNU/Linux EC2 Instance Created OK"
rm "$TMPSCRLNX" || echo ">>> ERRO removing temp file."
aws ec2 create-security-group --group-name rdp --description "RDP Access" --vpc-id $VPCID >/dev/null 2>&1 && echo "27/35 >>> [$SECONDREGION] Security Group Created OK"
echo -n "-> Waiting to get the ID for the resource(s) created."
while [[ -z "$OSWANID" ]] || [[ -z "$SGRDPID" ]]; do
        export OSWANID=`aws ec2 describe-instances --filters "Name=image-id,Values=$LNXAMI" "Name=instance-state-name,Values=running,pending" --query Reservations[*].Instances.InstanceId --output text`
        export SGRDPID=`aws ec2 describe-security-groups --filters "Name=group-name,Values=rdp" --query SecurityGroups[*].GroupId --output text`
        echo -n "."
done
echo " Got it! Moving on..."
aws ec2 authorize-security-group-ingress --group-id $SGRDPID --protocol tcp --port 3389 --cidr 0.0.0.0/0 >/dev/null 2>&1 && echo "28/35 >>> [$SECONDREGION] Firewall Rule Added OK"
# Disable the source/dest check
aws ec2 modify-instance-attribute --instance-id $OSWANID --no-source-dest-check >/dev/null 2>&1 && echo "29/35 >>> [$SECONDREGION] Source/Dest Check Disabled OK"
# Here we need to wait for the instance to install and configure allsoftware before attaching the EIP?
# We will add this IP after we start the Windows instance...
### h) Create and configure a Windows 2003 instance at the SECONDREGION/PRIVSUBNET, joining the AD Domain at the FIRSTREGION
TMPSCRWIN=`mktemp`
cat <<EOF > $TMPSCRWIN
aws ec2 run-instances --image-id $WINAMI --instance-type m1.medium --count 1 --subnet-id $PRIVSUBNETID --security-group-ids $SGRDPID --key-name $KEYNAME --user-data '<script>
netsh int ip set dns "local area connection" static $ADDSIP primary
netsh int ip add dns "local area connection" $ADDSIP
</script>
<powershell>
\$password = "$ADMINPASSWD" | ConvertTo-SecureString -asPlainText -Force
\$username = "$ADMINUSER"
\$credential = New-Object System.Management.Automation.PSCredential(\$username,\$password)
Add-Computer -domainname $ADDSDOMAIN -Credential \$credential -passthru
</powershell>' || exit 3
exit 0
EOF
chmod 700 $TMPSCRWIN
$TMPSCRWIN >/dev/null 2>&1 && echo "30/35 >>> [$SECONDREGION] Microsoft Windows EC2 Instance Created OK"
rm "$TMPSCRWIN" || echo ">>> ERRO removing temp file."
echo -n "-> Waiting to get the ID for the resource(s) created."
while [[ -z "$W2KINSTANCEID" ]] || [[ -z "$W2KPRIVIP" ]] || [[ -z "$LNXPRIVIP" ]]; do
        export W2KINSTANCEID=`aws ec2 describe-instances --filters "Name=image-id,Values=$WINAMI" "Name=instance-state-name,Values=running,pending" --query Reservations[*].Instances.InstanceId --output text`
        export W2KPRIVIP=`aws ec2 describe-instances --filters "Name=instance-id,Values=$W2KINSTANCEID" --query Reservations[*].Instances.NetworkInterfaces.PrivateIpAddresses.PrivateIpAddress --output text`
        export LNXPRIVIP=`aws ec2 describe-instances --filters "Name=instance-id,Values=$OSWANID" --query Reservations[*].Instances.NetworkInterfaces.PrivateIpAddresses.PrivateIpAddress --output text`
        echo -n "."
done
echo " Got it! Moving on..."
# At this stage the GNU/Linux instance should have finished the install script...
aws ec2 associate-address --instance-id $OSWANID --allocation-id $EIPID >/dev/null 2>&1 && echo "31/35 >>> [$SECONDREGION] Elastic IP Associated OK"
### g) Create and configure the routing tables;
aws ec2 create-route --route-table-id $RTBID --destination-cidr-block $VPCPRICIDR --instance-id $OSWANID >/dev/null 2>&1 && echo "32/35 >>> [$SECONDREGION] Route Created OK"
aws ec2 create-route --route-table-id $RTBID2 --destination-cidr-block $VPCPRICIDR --instance-id $OSWANID >/dev/null 2>&1 && echo "33/35 >>> [$SECONDREGION] Route Created OK"
aws ec2 create-tags --resources $OSWANID --tags Key=Name,Value=LinuxVPN >/dev/null 2>&1 && echo "34/35 >>> [$SECONDREGION] GNU/Linux VPN Tag Created OK"
aws ec2 create-tags --resources $W2KINSTANCEID --tags Key=Name,Value=Windows2003 >/dev/null 2>&1 && echo "35/35 >>> [$SECONDREGION] Windows 2003 Tag Created OK"
echo "-----------------------------------------------------------------"
echo '-------- >>> New DATACENTER Deployed Successfully!'
echo "-------- >>> GNU/Linux OpenSWAN Server Private IP: $LNXPRIVIP"
echo "-------- >>> Microsoft Windows 2003 Server Private IP: $W2KPRIVIP"
echo "-----------------------------------------------------------------"

# We get here, good...
exit 0
