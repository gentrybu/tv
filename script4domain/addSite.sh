#!/bin/bash
source basic_option_domain.sh
source /home/TVadmin/.bashrc

num=1
for thirdnum in $(seq 1 39)
do
	for fourthnum in $(seq 1 250)
	do
		modid=$(expr $num % 299)
		domainid=$(expr $modid + 16)
		addsite autoSite$num [172.1.$thirdnum.$fourthnum/32,172.2.$thirdnum.$fourthnum/32,172.3.$thirdnum.$fourthnum/32] $domainid
		let num++
	done
done
