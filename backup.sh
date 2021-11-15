#!/usr/bin/env bash
#2021-11-14 - Drew Petipas - This script will pull data using rsync over SSH to the backup server. This bash script is called as a cron job by root.

# VARIABLES CONF

bash ./backup_alert_start.sh

source backup.conf >> /dev/null
if [ $? != 0 ]; then
	echo -e "$(date "+%F %T") [ERROR $?] backup.conf is missing."
	exit 1
fi

# Test if host is pingable
ping -c 1 $remote_server >> /dev/null
if [ $? != 0 ]; then
	echo -e "$(date "+%F %T") [ERROR $?] Remote server is down." >> $log_location
	exit 1
fi


# Test if SSH is up
ssh -q $remote_user@$remote_server exit
if [ $? = 255 ]; then
	echo -e"$(date "+%F %T") [ERROR $?] SSH is down." >> $log_location
	exit 1
fi

# Begin backup
echo -e "$(date "+%F %T") [START] Backup started." >> $log_location
rsync --archive --quiet --ignore-existing --delete-during --exclude $exclude --compress $remote_user@$remote_server:$remote_dir/* $backup_dir
rsync_exit=$?
echo -e "$(date "+%F %T") [END] Backup ended." >> $log_location

# Check backup exit value
if [ $rsync_exit = 0 ]; then
	echo -e "$(date "+%F %T") [SUCCESS] Backup completed successfully." >> $log_location
	bash ./backup_alert_success.sh
	exit 0
else
	echo -e "$(date "+%F %T") [ERROR $rsync_exit] Backup failed." >> $log_location
	exit 1
fi
