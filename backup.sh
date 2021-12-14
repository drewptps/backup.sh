#!/usr/bin/env bash
#2021-11-14 - Drew Petipas - This script will pull data using rsync over SSH to the backup server. This bash script is called as a cron job by root.

# Call script for custom alert - alert that script has started. If I don't see an alert for success, I know something went wrong.
bash /usr/local/bin/backup/backup_alert_start.sh

# Variables .conf
source /usr/local/bin/backup/backup.conf

# Log testing start
echo "$(date "+%F %T") [INIT] Script initializing, testing..." >> $log_location

# Test that backup.conf was sourced
if [ $? != 0 ]; then
	echo "$(date "+%F %T") [ERROR $?] backup.conf is missing." >> $log_location
	exit 1
fi

# Test if host is pingable
ping -c 1 $remote_server >> /dev/null
if [ $? != 0 ]; then
	echo "$(date "+%F %T") [ERROR $?] Remote server is down." >> $log_location
	exit 1
fi

# Test if SSH is up
ssh $remote_user@$remote_server exit
if [ $? = 255 ]; then
	echo "$(date "+%F %T") [ERROR $?] SSH is down." >> $log_location
	exit 1
fi

# Begin backup
echo "$(date "+%F %T") [START] Backup started." >> $log_location
rsync --archive --ignore-existing --delete-during --exclude $exclude --compress $remote_user@$remote_server:$remote_dir/* $backup_dir >> /dev/null
rsync_exit=$?
echo "$(date "+%F %T") [END] Backup ended." >> $log_location

# Check backup exit value
if [ $rsync_exit = 0 ]; then
	echo "$(date "+%F %T") [SUCCESS] Backup completed successfully." >> $log_location
	# Call script for custom alert - alert that the backup was successful.
	bash /usr/local/bin/backup/backup_alert_success.sh
	exit 0
else
	echo "$(date "+%F %T") [ERROR $rsync_exit] Backup failed." >> $log_location
	exit 1
fi
