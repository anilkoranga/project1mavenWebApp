#!/bin/sh
HOST=$(cat /etc/ansible/hosts)
ssh azureuser@$HOST "sudo chown -R  azureuser:azureuser /var/run/docker.sock && docker stop con1 && docker rm con1 && docker pull anilkoranga/project1:latest && docker run -d -p 80:8080 --name con1 anilkoranga/project1:latest "

 

