#!/bin/bash

#Variable declarations
CHROOTS="precise kali trusty"
DRIVE_PATH="/media/removable/BACKUPS"
now=$(date +"%Y-%m-%d-%S")
LOG_PATH="$DRIVE_PATH/logs/chmod_manager.$now.log"

#function declarations
function backup {
clear
select chmod in $CHROOTS; do
	echo Backing up precise chroot at "$DRIVE_PATH/$chmod" >> $LOG_PATH
	SECONDS=0
	sudo  edit-chroot -f "$DRIVE_PATH/$chmod" -b "$chmod"
	report_time $SECONDS
	exit_or_return	
done
}

function restore {
clear
select chmod in $CHROOTS; do
	SECONDS=0
	echo Restoring precise chroot... >> $LOG_PATH
	sudo edit-chroot -f "$DRIVE_PATH/$chmod"  "$chmod" -r
	report_time $SECONDS
	exit_or_return
done
}

function purge {
clear
select chmod in $CHROOTS; do
	SECONDS=0
	echo Purging precise chroot... >> $LOG_PATH
	sudo delete-chroot "$chmod"
	report_time $SECONDS
	exit_or_return
done
}


report_time() {
 if [ $1 -lt 60 ]; then
	echo Process took $1 seconds... >> $LOG_PATH
 else
	echo Process took $(($1 / 60 ))minutes and $(( $1 % 60)) seconds. >> $LOG_PATH
 fi
}

function exit_or_return {
echo ""
cat $LOG_PATH
echo ""

CHOICE="Return Exit"
select opt1 in $CHOICE; do
	if [ "$opt1" = "Return" ]; then
		main
	elif [ "$opt1" = "Exit" ]; then
		echo exiting...
		clear
		exit
	else
		echo Not a valid option...
		exit_or_return
	fi
done
}

#Menu Tree
function main {
clear
OPTIONS="Backup Restore Purge Exit"
select opt in $OPTIONS; do
	if [ "$opt" = "Backup" ]; then
		backup
	elif [ "$opt" = "Restore" ]; then
		restore
	elif [ "$opt" = "Purge" ]; then
		purge
	elif [ "$opt" = "Exit" ]; then
		echo Exiting
		exit
	else
		clear
		echo bad option
		clear
		main
	fi
done
}


#init
main
