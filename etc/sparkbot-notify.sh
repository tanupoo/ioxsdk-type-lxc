#! /bin/sh
# /etc/init.d/sparkbot-notify

## BEGIN INIT INFO
# Provides:  sparkbot-notify.sh
# Required-Start:   $remote_fs $syslog
# Required-Stop:    $remote_fs $syslog
# Default-Start:    2 3 4 5
# Short-Description: Spark Bot Notify
### END INIT INFO

set -e

SPARKBOT_DIR=/usr/bin
#SPARKBOT_DEBUG=-dd

export CAF_APP_PATH=/data
export CAF_APP_CONFIG_FILE=package_config.ini

case "$1" in
start)
	echo "Starting program"
	# run application you want to start
        if [ -z "${SPARKBOT_DEBUG}" ] ; then
            sleep 15
            while true
            do
                ${SPARKBOT_DIR}/sparkbot-notify
                # restart if when the bot exits by an error.
                sleep 15
            done
        else
            ${SPARKBOT_DIR}/sparkbot-notify ${SPARKBOT_DEBUG}
        fi
	;;
stop)
	echo "Stopping program"
	# kill application you want to stop
	killall sparkbot-notify.sh
	;;
*)
	echo "Usage: $0 {start|stop}" exit 1
	;;
esac
