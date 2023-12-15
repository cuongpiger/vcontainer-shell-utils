#!/bin/bash

########################################################################################################################
# Author: Cuong. Duong Manh <cuongdm8499@gmail.com>
# Description: This file contains some functions to log
########################################################################################################################

# Print message to stderr
function echo_stderr {
  >&2 echo "$@"
}

# Log message with level
function log {
  local -r level="$1"
  local -r message="$2"
  local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local -r script_name="${0##*/}#L${BASH_LINENO[1]}"
  local -r function="${FUNCNAME[2]}"
  echo_stderr -e "${timestamp} [${level}] [$script_name] [${function}()] ${message}"
}

# Log message with level DEBUG
function log_debug {
  if [ -z "${OTEL_LOG_LEVEL-}" ]; then
    local -r message="$1"
	else
    local -r message="$1"
    log "DEBUG" "$message"
	fi
}

# Log message with level INFO
function log_info {
  local -r message="$1"
  log "INFO" "$message"
}

# Log message with level ERROR
function log_error {
  local -r message="$1"
  log "ERROR" "$message"
}