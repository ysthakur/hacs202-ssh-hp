#!/bin/bash
cp /root/MITM_data/login_attempts/ssh-hp.txt /root/data/ssh-hp/login_attempts/$(TZ='America/New_York' date "+%m-%d-%Y").txt
sleep 3
truncate -s 0 /root/MITM_data/login_attempts/ssh-hp.txt
