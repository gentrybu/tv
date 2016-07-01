#!/bin/bash
source basic_option_domain.sh
source /home/TVadmin/.bashrc
#create a number of domain
for domainid in $(seq 16 316)
do
	adddomain $domainid
done
