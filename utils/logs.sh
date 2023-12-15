#!/bin/bash

function echo_stderr {
  >&2 echo "$@"
}

function log {
  local -r level="$1"
  local -r message="$2"
  local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local -r script_name="${0##*/}#L${BASH_LINENO[1]}"
  local -r function="${FUNCNAME[2]}"
  echo_stderr -e "${timestamp} [${level}] [$script_name] [${function}()] ${message}"
}

function log_debug {
  if [ -z "${OTEL_LOG_LEVEL-}" ]; then
    local -r message="$1"
	else
    local -r message="$1"
    log "DEBUG" "$message"
	fi
}

function log_info {
  local -r message="$1"
  log "INFO" "$message"
}

function log_error {
  local -r message="$1"
  log "ERROR" "$message"
}