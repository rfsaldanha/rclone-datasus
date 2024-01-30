#!/bin/bash

# Activate conda env
# https://saturncloud.io/blog/calling-conda-source-activate-from-bash-script-a-guide/
source activate rclone

# Backup



# Delete log file
rm rclone_datasus_log.txt

# Create log file, write system time
date >> rclone_datasus_log.txt
echo -e "\n" >> rclone_datasus_log.txt

# Mirror datasus FTP
rclone sync :ftp:dissemin/publicos digitalocean:datasus-ftp-mirror --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt

# Deactivate conda env
conda deactivate
