# tf-azure-tfcloud-01
Tests with terraform cloud


KEY_NAME=mykey
PUB_IP=$(terraform output  -json | jq -r .public_ip.value)
AZ_USER=$(terraform output  -json | jq -r .vm_admin_user.value)
echo "connecting to: $PUB_IP as $AZ_USER"
echo "with key $KEY_NAME"
ssh -i ~/.ssh/$KEY_NAME $AZ_USER@$PUB_IP