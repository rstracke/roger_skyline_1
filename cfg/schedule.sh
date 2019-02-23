#!/bin/bash

copy_scripts() {
	cp res/update_script.sh /root/scripts/
	cp res/cron_check.sh /root/scripts/
}

to_crontab() {
	crontab res/crontab.dat
}