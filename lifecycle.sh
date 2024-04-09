#!/bin/bash
#Call this script with screen ./
HONEYPOTNAME=$1
LOGFILE="/root/containers/$HONEYPOTNAME/rootfs/var/log/auth.log"

# Function to perform actions when a successful login is detected for user1
function on_successful_login {
    # Here if we find someone login we give them 20 mins of play time before kicking them out
    # screen -dmS $HONEYPOTNAME-tail1 bash -c "tail -f /root/containers/$1/rootfs/var/log/auth.log > /root/data/$1_auth_log_$(date '+%Y-%m-%d_%H:%M:%S')" # /root/copy_auth.sh $HONEYPOTNAME
    echo "Successful login for user1 detected, pausing for 10 seconds..."
    sleep 30  # Waits for lifecycle time (3 hours)
    echo "Stopping and restoring the $1 container..."
    #Here we stop refresh and restart the honey pot
    # screen -S $HONEYPOTNAME-tail1 -X quit

    # Stop log collection (screen)
    # Stop MITM (screen) PLACE 1
    echo "Ending ssh-mitm screen session"
    screen -X -S 'ssh-mitm' quit
    # Copy MITM files
    TIME=$(TZ='America/New_York' date "+%m-%d-%Y-%H")
    mv /root/MITM_data/login_attempts/$HONEYPOTNAME.txt /root/data/ssh-hp/login_attempts/$TIME.txt
    mv /root/MITM_data/logins/$HONEYPOTNAME.txt /root/data/ssh-hp/logins/$TIME.txt
    mkdir -p /root/data/ssh-hp/sessions/$TIME
    mv /root/MITM_data/sessions/*.gz /root/data/ssh-hp/sessions/$TIME
    echo "mitm files moved"

    lxc stop $HONEYPOTNAME
    sleep 10
    lxc restore $HONEYPOTNAME ssh-snapshot
    echo "restarting"
    sleep 10
    lxc start $HONEYPOTNAME

    # Start the log collection (tail -f in a screen)
    # Start the MITM  (in a screen)  PLACE 2
    screen -dmS ssh-mitm node /root/honeypots/MITM/mitm/index.js mitm_ssh.js

    echo "Actions completed."
}

#ALL OF THESE TO BE REPLACED WITH CODE
# stop container
echo "Starting the MITM and starting the honeypot"
lxc stop $HONEYPOTNAME
sleep 10
# restore container
lxc restore $HONEYPOTNAME ssh-snapshot
# start container  == Clean state/running container
sleep 10
lxc start $HONEYPOTNAME
# start the log collection (tail -f in a  screen)
#IDK WHAT THIS WANTS FROM ME
# start the MITM  (in a screen) PLACE 3
screen -dmS ssh-mitm node /root/honeypots/MITM/mitm/index.js mitm_ssh.js

# Monitor the log file for new entries containing "Accepted password"
while true; do
    # To make sure the script does not get spammed, there is a one-minute cooldown before checking
    echo "waiting for an attack"
    echo "NAME IS $HONEYPOTNAME"
    sleep 10
    cat $LOGFILE | while read LINE; do
        echo "$LINE" | grep "Accepted password" &> /dev/null
        if [ $? -eq 0 ]; then
            # The grep command found the pattern, call the function
            on_successful_login
        fi
    done
done
