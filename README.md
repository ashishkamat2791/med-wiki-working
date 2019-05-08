# med-wiki-working

## Steps

 1) bootstrap EC2 instance with docker and docker-compose installed
 2) make an AMI and pass this launch configuration
3) scale in scale out using ASG with min 1 max 3 (random)
4) sync data of www directory s3 every 5 minutes so that piolt version will be avaialbe during Disaster recovery using hosted S3 website
5) get endpoint of RDS (username and password will be ) and pass to parameter
6) Get public IP of EC2 instances (dynamci inventory is preferrable but didint worked on this)
6) using Ansible script copy docker-compose file, with modification of database hostname, username, password


### update
1) added script to install docker-compose on master
2) added ansible-playbook (run locally) to intialize swarm cluster on master node
3) added ansible-playbook (run locally) to join the swarm-network

After everything is up by terraform grab the public-ip and copy into aws_hosts inside [master] to get compose-up

run terraform output to get rds endpoint, user-name, password to setup mediawiki
