#!/bin/bash

# Activate conda env
# https://saturncloud.io/blog/calling-conda-source-activate-from-bash-script-a-guide/
source activate rclone

## Backup: Sync backup with mirror

# Current mirror content to backup
# rclone sync digitalocean:datasus-ftp-mirror digitalocean:datasus-ftp-backup

## Update: Sync mirror with DataSUS

# Delete log and tree files
rm rclone_datasus_log.txt
rm rclone_datasus_files_tree.txt
rm rclone_datasus_dirs_tree.txt

# Create log file, write system time
date > rclone_datasus_log.txt
echo -e "\n" >> rclone_datasus_log.txt

# Mirror datasus FTP
rclone sync :ftp:dissemin/publicos/SIM digitalocean:datasus-ftp-mirror/SIM --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt
rclone sync :ftp:dissemin/publicos/SINASC digitalocean:datasus-ftp-mirror/SINASC --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt


# Create tree file of mirror
rclone tree digitalocean:datasus-ftp-mirror > rclone_datasus_files_tree.txt
rclone tree digitalocean:datasus-ftp-mirror --dirs-only > rclone_datasus_dirs_tree.txt

# Write end time
echo -e "\n" >> rclone_datasus_log.txt
date >> rclone_datasus_log.txt

# Copy log and tree files to mirror
rclone copy rclone_datasus_log.txt digitalocean:datasus-ftp-mirror
rclone copy rclone_datasus_files_tree.txt digitalocean:datasus-ftp-mirror
rclone copy rclone_datasus_dirs_tree.txt digitalocean:datasus-ftp-mirror

# Deactivate conda env
conda deactivate
