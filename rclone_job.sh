#!/bin/bash

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
## SIM
echo -e "SIM files\n" >> rclone_datasus_log.txt
rclone sync :ftp:dissemin/publicos/SIM datasus-ftp-mirror:s3datasus/SIM --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt --exclude=*.{xml,csv}

## SINASC
echo -e "SINASC files\n" >> rclone_datasus_log.txt
rclone sync :ftp:dissemin/publicos/SINASC datasus-ftp-mirror:s3datasus/SINASC --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt --exclude=*.{xml,csv}

# SIH
echo -e "SIH files\n" >> rclone_datasus_log.txt
rclone sync :ftp:dissemin/publicos/SIHSUS datasus-ftp-mirror:s3datasus/SIHSUS --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt --exclude "*.xml"

# SIA
#rclone sync :ftp:dissemin/publicos/SIASUS digitalocean:datasus-ftp-mirror/SIASUS --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt --exclude "*.xml"

# SINAN
#rclone sync :ftp:dissemin/publicos/SINAN digitalocean:datasus-ftp-mirror/SINAN --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt --exclude "*.xml"

# CNES
#rclone sync :ftp:dissemin/publicos/CNES digitalocean:datasus-ftp-mirror/CNES --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt --exclude "*.xml"

# Create tree file of mirror
rclone tree datasus-ftp-mirror:s3datasus > rclone_datasus_files_tree.txt
rclone tree datasus-ftp-mirror:s3datasus --dirs-only > rclone_datasus_dirs_tree.txt

# Write end time
echo -e "\n" >> rclone_datasus_log.txt
date >> rclone_datasus_log.txt

# Copy log and tree files to mirror
rclone copy rclone_datasus_log.txt datasus-ftp-mirror:s3datasus
rclone copy rclone_datasus_files_tree.txt datasus-ftp-mirror:s3datasus
rclone copy rclone_datasus_dirs_tree.txt datasus-ftp-mirror:s3datasus
