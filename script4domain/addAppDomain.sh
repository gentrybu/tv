#!/bin/bash
source basic_option_domain.sh
source /home/TVadmin/.bashrc

#create a number of App
	number=1000
	for num in $(seq 1 $number)
	do
		modid=$(expr $num % 299)
		domainid=$(expr $modid + 16)
		port=$[$num+6000]
		addapp autoApp$num $port $domainid
	done	

	
