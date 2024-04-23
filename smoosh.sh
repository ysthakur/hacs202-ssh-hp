#!/bin/sh

DATA="/root/data/ssh-hp"
cat $DATA/login_attempts/*.txt > $DATA/login_attempts.txt
cat $DATA/logins/*.txt > $DATA/logins.txt

