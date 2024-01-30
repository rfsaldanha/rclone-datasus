#!/bin/bash

# Activate conda env
# https://saturncloud.io/blog/calling-conda-source-activate-from-bash-script-a-guide/
source activate rclone

# Current mirror content to backup
rclone sync digitalocean:datasus-ftp-mirror digitalocean:datasus-ftp-backup

# Delete log and tree files
rm rclone_datasus_log.txt
rm rclone_datasus_tree.txt

# Create log file, write system time
date > rclone_datasus_log.txt
echo -e "\n" >> rclone_datasus_log.txt

# Mirror datasus FTP
rclone sync :ftp:dissemin/publicos digitalocean:datasus-ftp-mirror --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt

# Create tree file of mirror
rclone tree digitalocean:datasus-ftp-mirror > rclone_datasus_tree.txt

# Copy log and tree files to mirror
rclone copy rclone_datasus_log.txt digitalocean:datasus-ftp-mirror
rclone copy rclone_datasus_tree.txt digitalocean:datasus-ftp-mirror

# Write end time
echo -e "\n" >> rclone_datasus_log.txt
date >> rclone_datasus_log.txt

# Deactivate conda env
conda deactivate
