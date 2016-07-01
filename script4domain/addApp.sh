#!/bin/bash
source basic_option.sh
source /home/TVadmin/.bashrc

#create a number of App
	number=1000
	for num in $(seq 1 $number)
	do
		port=$[$num+6000]
		addapp autoApp$num $port
	done	

	
