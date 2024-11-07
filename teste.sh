# Copy log with date time stamp
FILE_LOG="rclone_datasus_log_$(date +"%F_%T").txt"
cp rclone_datasus_log.txt rclone-logs/${FILE_LOG}
rclone copy rclone-logs/${FILE_LOG} digitalocean:datasus-ftp-mirror/rclone-logs