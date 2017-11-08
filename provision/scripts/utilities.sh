#! /bin/bash
#
# utilities.sh
# Copyright (C) 2017 Ryan Mackenzie White <ryan.white4@canada.ca>
#
# Colors for pretty screen
# logger for logging
# executor for logging commands 
##################################################
# Colors
# colors for interactive
red='\e[0;31m'
green='\e[0;32m'
yellow='\e[1;33m'
cyan='\e[0;36m'
nc='\e[0m'

reset=${nc}
debug="${yellow} DEBUG: ${reset}" 
warn="${yellow} WARNING: ${reset}" 
success="${green} SUCCESS: ${reset}"
error="${red} ERROR: ${reset}"
question="${cyan} Question: ${reset}"
info="${cyan} INFO: ${reset}"
##################################################

# Append text to log file
# Echo content to stdout
# $ param   str Content 
logger() {
    # Strip colors from log
    echo -e "$(date) $1" | perl -pe 's/\e\[?.*?[\@-~]//g' >> $__LOGGER_FILEPATH/$__LOGGER_FILENAME
    echo -e "$(date) $1"
}

logger_clear() {
    echo -e "${info} Clear the log"
    echo "" > $__LOGGER_FILEPATH/$__LOGGER_FILENAME
}

logger_clear
if [[ $__DEBUG == true ]]; then
    logger "${DEBUG} DEBUG: ${__DEBUG}"
    logger "Print all commands, do not execute"
fi

# Pass sudo command
# $ param str Command
executor() {
    COMMAND="$@"
    if [[ $__DEBUG == true ]]; then
        logger "${debug} $@"
    else
        logger "${info} Execute $@"
        ${COMMAND[@]} 
    fi
}

################################################
