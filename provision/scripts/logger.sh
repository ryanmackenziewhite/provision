#! /bin/bash
#
# logger.sh
# Copyright (C) 2017 Ryan Mackenzie White <ryan.white4@canada.ca>
#
#

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


