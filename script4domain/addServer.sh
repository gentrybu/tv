#!/bin/bash
source basic_option.sh
source /home/TVadmin/.bashrc

for num in $(seq 1 100)
do
	addserver 172.1.1.$num autoServer$num
done
