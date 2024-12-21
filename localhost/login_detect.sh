#!/bin/bash

LOG_FILE=/tmp/.font-linux

if [ ! -e ${LOG_FILE} ]; then
    touch ${LOG_FILE}
fi

(
cat <<EOF

LOGIN NOTIFICATION



Host:  $(hostname)
User:  $(whoami)
Date:  $(date '+%Y-%m-%d %H:%M:%S')
Uptime:  $(uptime)



Who is logged in?

$(who)


EOF
) | sendemail -l /tmp/.font-linux \
    -f "myemail@gmail.com" \
    -u "Login Attempt at $(date '+%Y-%m-%d %H:%M:%S') from $(whoami)" \
    -t "mycorporate@name.com" \
    -s "smtp.gmail.com:587" \
    -o tls=yes \
    -xu "myemail@gmail.com" \
    -xp "MyPassword" 2>&1 > /dev/null &

