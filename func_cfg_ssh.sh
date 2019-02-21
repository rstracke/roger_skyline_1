#!/bin/bash

SSH_CFG_FILE=$"/etc/ssh/sshd_config"
source func_str_processing.sh
get_current_port(){
	get_field_value "Port" $SSH_CFG_FILE 
	CURRENT_PORT=$FIELD_VALUE
}
get_current_port
echo $CURRENT_PORT
