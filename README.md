# backup.sh
Default location of this script is /usr/local/bin/backup.

I use this script to back up my main server. This script exists on my local backup server and my DR site.

I use cron to run this once a week on my local backup server, and weekly on my remote DR site as well.

TEMPLATE_backup.conf must be renamed to backup.conf before using.
