#!/bin/bash

myhosts=('jiffy' 'btcpi.m' 'pi.m' 'snow.m')

for host in "${myhosts[@]}"; do
	echo "$host:";
	ssh -A $host "cd ~/.myconf/; git pull"
done
