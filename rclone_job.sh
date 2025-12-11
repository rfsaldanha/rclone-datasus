#!/bin/bash

## Backup: Sync backup with mirror

# Current mirror content to backup
# rclone sync digitalocean:datasus-ftp-mirror digitalocean:datasus-ftp-backup

## Update: Sync mirror with DataSUS

curl -d "Update job start" ntfy.sh/ocs_update_datasus

# Rename old log and tree files
mv -f rclone_datasus_log.txt rclone_datasus_log_last_run.txt
mv -f rclone_datasus_files_tree.txt rclone_datasus_files_tree_last_run.txt
mv -f rclone_datasus_dirs_tree.txt rclone_datasus_dirs_tree_last_run.txt
mv -f rclone_datasus_full_path.txt rclone_datasus_full_path_last_run.txt

# Create log file, write system time
touch rclone_datasus_log.txt
date > rclone_datasus_log.txt
echo -e "\n" >> rclone_datasus_log.txt

# Mirror datasus FTP
## SIM
echo -e "SIM files\n" >> rclone_datasus_log.txt
rclone sync :ftp:dissemin/publicos/SIM digitalocean:datasus-ftp-mirror/SIM --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt --exclude=*.{xml,csv}

## SINASC
echo -e "SINASC files\n" >> rclone_datasus_log.txt
rclone sync :ftp:dissemin/publicos/SINASC digitalocean:datasus-ftp-mirror/SINASC --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt --exclude=*.{xml,csv}

# SIH
echo -e "SIH files\n" >> rclone_datasus_log.txt
rclone sync :ftp:dissemin/publicos/SIHSUS digitalocean:datasus-ftp-mirror/SIHSUS --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt --exclude=*.{xml,csv}

# SIA
echo -e "SIA files\n" >> rclone_datasus_log.txt
rclone sync :ftp:dissemin/publicos/SIASUS digitalocean:datasus-ftp-mirror/SIASUS --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt --exclude=*.{xml,csv}

# SINAN
echo -e "SINAN files\n" >> rclone_datasus_log.txt
rclone sync :ftp:dissemin/publicos/SINAN digitalocean:datasus-ftp-mirror/SINAN --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt --exclude=*.{xml,csv}

# CNES
echo -e "CNES files\n" >> rclone_datasus_log.txt
rclone sync :ftp:dissemin/publicos/CNES digitalocean:datasus-ftp-mirror/CNES --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt --exclude=*.{xml,csv}

# ESUSNOTIFICA
echo -e "ESUSNOTIFICA files\n" >> rclone_datasus_log.txt
rclone sync :ftp:dissemin/publicos/ESUSNOTIFICA digitalocean:datasus-ftp-mirror/ESUSNOTIFICA --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt --exclude=*.{xml,csv}

# DADOSABERTOS
echo -e "DADOSABERTOS files\n" >> rclone_datasus_log.txt
rclone sync :ftp:dissemin/publicos/Dados_Abertos digitalocean:datasus-ftp-mirror/Dados_Abertos --ftp-host=ftp.datasus.gov.br --ftp-user=anonymous --ftp-pass=$(rclone obscure dummy) --ftp-concurrency=5 --verbose --log-file=rclone_datasus_log.txt --exclude=*.{xml,csv}

# Create tree file of mirror
rclone tree digitalocean:datasus-ftp-mirror --exclude rclone-logs/ > rclone_datasus_files_tree.txt
rclone tree digitalocean:datasus-ftp-mirror --exclude rclone-logs/ --dirs-only > rclone_datasus_dirs_tree.txt
rclone tree digitalocean:datasus-ftp-mirror --exclude rclone-logs/ --full-path --noindent > rclone_datasus_full_path.txt

# Write end time
echo -e "\n" >> rclone_datasus_log.txt
date >> rclone_datasus_log.txt

# Copy log and tree files to mirror
rclone copy rclone_datasus_log.txt digitalocean:datasus-ftp-mirror
rclone copy rclone_datasus_files_tree.txt digitalocean:datasus-ftp-mirror
rclone copy rclone_datasus_dirs_tree.txt digitalocean:datasus-ftp-mirror
rclone copy rclone_datasus_full_path.txt digitalocean:datasus-ftp-mirror

# Copy log with date time stamp
FILE_LOG="rclone_datasus_log_$(date +"%F_%T").txt"
cp rclone_datasus_log.txt rclone-logs/${FILE_LOG}
rclone copy rclone-logs/${FILE_LOG} digitalocean:datasus-ftp-mirror/rclone-logs
rclone tree digitalocean:datasus-ftp-mirror/rclone-logs --full-path --noindent > rclone_datasus_logs.txt
rclone copy rclone_datasus_logs.txt digitalocean:datasus-ftp-mirror

# Parse log to database
Rscript rclone-datasus/parse_log.R

curl -d "Update job end" ntfy.sh/ocs_update_datasus