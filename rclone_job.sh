#!/bin/bash

## Backup: Sync backup with mirror

# Current mirror content to backup
# rclone sync digitalocean:datasus-ftp-mirror digitalocean:datasus-ftp-backup

## Update: Sync mirror with DataSUS

# Rename old log and tree files
mv -f rclone_datasus_log.txt rclone_datasus_log_last_run.txt
mv -f rclone_datasus_files_tree.txt rclone_datasus_files_tree_last_run.txt
mv -f rclone_datasus_dirs_tree.txt rclone_datasus_dirs_tree_last_run.txt

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
rclone sync :ftp:dissemin/publicos/SIHSUS datasus-ftp-mirror:s3datasus/SIHSUS --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt --exclude=*.{xml,csv}

# SIA
echo -e "SIA files\n" >> rclone_datasus_log.txt
rclone sync :ftp:dissemin/publicos/SIASUS datasus-ftp-mirror:s3datasus/SIASUS --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt --exclude=*.{xml,csv}

# SINAN
echo -e "SINAN files\n" >> rclone_datasus_log.txt
rclone sync :ftp:dissemin/publicos/SINAN datasus-ftp-mirror:s3datasus/SINAN --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt --exclude=*.{xml,csv}

# CNES
echo -e "CNES files\n" >> rclone_datasus_log.txt
rclone sync :ftp:dissemin/publicos/CNES datasus-ftp-mirror:s3datasus/CNES --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt --exclude=*.{xml,csv}

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
