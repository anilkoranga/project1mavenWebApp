#!/bin/sh
az vm show -d -g myResourceGroup -n myVM --query publicIps -o tsv > /etc/ansible/hosts
