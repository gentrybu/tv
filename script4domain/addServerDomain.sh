#!/bin/bash
source basic_option_domain.sh
source /home/TVadmin/.bashrc

for domainid in $(seq 16 314)
do
	for num in $(seq 1 30)
	do
		thirdnum=$(expr $domainid % 150)
		addserver 172.1.$thirdnum.$num autoServer$num $domainid
	done
done
