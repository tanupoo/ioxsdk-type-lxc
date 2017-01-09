#! /bin/sh
# /etc/init.d/sparkbot-notify

export CAF_APP_PATH=/data
export CAF_APP_CONFIG_FILE=package_config.ini

export CAF_APP_PERSISTENT_DIR=.
export CAF_APP_LOG_DIR=.
export CAF_APP_CONFIG_DIR=.
export CAF_APP_USERNAME=.
export CAF_HOME=.
export CAF_HOME_ABS_PATH=.
export CAF_MODULES_PATH=.
export CAF_APP_DIR=.
export CAF_MODULES_DIR=.
export CAF_APP_ID=.

case "$1" in
start)
	sleep 15
	echo "Starting program"
	# run application you want to start
	#/usr/bin/sparkbot-notify -dd
	/usr/bin/sparkbot-notify
	;;
stop)
	echo "Stopping program"
	# kill application you want to stop
	/usr/bin/sparkbot-notify
	;;
*)
	echo "Usage: /etc/init.d/sparkbot-notify {start|stop}" exit 1
	;;
esac
