#!/usr/bin/env bash

# shellcheck disable=SC1090

function _toolbox_exec_log() {
  local title
  title=${1:-"Execute command"}

  shift

  local args
  args=$(toolbox_util_array_join "$@")

  _toolbox_exec_log_cmd "${title}" "${args}"
}

function _toolbox_exec_log_cmd() {
  TOOLBOX_EXEC_LOG_PREFIX=${TOOLBOX_EXEC_LOG_PREFIX-"---> "}
  TOOLBOX_EXEC_LOG_LEVEL_TITLE=${TOOLBOX_EXEC_LOG_LEVEL_TITLE-INFO}
  TOOLBOX_EXEC_LOG_LEVEL_CMD=${TOOLBOX_EXEC_LOG_LEVEL_CMD-INFO}

  local title
  title=${1:-"Execute command"}

  local cmd
  cmd=${2}

  local _cmd_log_color="${GREEN}"
  if [ "${TOOLBOX_EXEC_LOG_LEVEL_TITLE}" = "DEBUG" ] || [ "${TOOLBOX_EXEC_LOG_LEVEL_TITLE}" = "TRACE" ]; then
    _cmd_log_color="${PURPLE}"
  fi

  _log "${TOOLBOX_EXEC_LOG_LEVEL_TITLE}" "${BLUE}${TOOLBOX_EXEC_LOG_PREFIX}${title}:${RESTORE}"
  _log "${TOOLBOX_EXEC_LOG_LEVEL_CMD}" "${_cmd_log_color}${cmd}${RESTORE}"
}

function toolbox_exec {
  _toolbox_exec_log "$@"
  shift
  exec "$@"
}

function toolbox_run {
  _toolbox_exec_log "$@"
  shift
  "$@"
}

function toolbox_exec_handler {
  _log TRACE "Start 'toolbox_exec_handler' function with args: $*"
  toolbox_exec_hook "toolbox_exec_handler" "before"
  "$@"
  toolbox_exec_hook "toolbox_exec_handler" "after"
  _log TRACE "End 'toolbox_exec_handler' function with args: $*"
}

function toolbox_exec_hook {
  local _context="${1}"
  local _hook="${2}"

  TOOLBOX_TOOL_DIRS=${TOOLBOX_TOOL_DIRS:-toolbox}
  TOOLBOX_EXEC_SUBSHELL=${TOOLBOX_EXEC_SUBSHELL:-true}

  for i in ${TOOLBOX_TOOL_DIRS//,/ }
  do
    _log DEBUG "Check if hooks dir exists at path: ${i}/hooks"
    if [[ -d "${i}/hooks" ]]; then
      local _hooks_path="${i}/hooks"
      _log DEBUG "Check if hooks exist: ${_hooks_path}/${_context}/${_hook}"
      if [[ -f "${_hooks_path}/${_context}/${_hook}" ]]; then
        _log DEBUG "Execute hook: ${_hooks_path}/${_context}/${_hook} $*"
        _log DEBUG "$(cat "${_hooks_path}"/"${_context}"/"${_hook}")"
        if [ "${TOOLBOX_EXEC_SUBSHELL}" = true ]; then
          (
            . "${_hooks_path}"/"${_context}"/"${_hook}" "$@"
          )
        else
          . "${_hooks_path}"/"${_context}"/"${_hook}" "$@"
        fi
      fi

      if [[ -d "${_hooks_path}/${_context}/${_hook}" ]]; then
        for f in "${_hooks_path}"/"${_context}"/"${_hook}"/*
        do
          _log DEBUG "Execute hook: ${f} $*"
          _log DEBUG "$(cat "${f}")"
          if [ "${TOOLBOX_EXEC_SUBSHELL}" = true ]; then
            (
            . "${f}" "$@"
            )
          else
            . "${f}" "$@"
          fi
        done
      fi
    fi
  done
}

function toolbox_exec_tool {
  TOOLBOX_TOOL=${TOOLBOX_TOOL:-${2}}
  TOOLBOX_TOOL_PATH=${TOOLBOX_TOOL_PATH:-}
  TOOLBOX_TOOL_DIRS=${TOOLBOX_TOOL_DIRS:-toolbox}

  if [ ! -f "${TOOLBOX_TOOL}" ]; then
  IFS=" "
  for i in $(echo "$TOOLBOX_TOOL_DIRS" | sed "s/,/ /g")
  do
    _log DEBUG "Check if tool exists at path: ${i}/${TOOLBOX_TOOL}"
    if [[ -f "${i}/${TOOLBOX_TOOL}" ]]; then
      TOOLBOX_TOOL_PATH="${i}/${TOOLBOX_TOOL}"
      break
    fi
  done
  fi

  if [[ -z ${TOOLBOX_TOOL_PATH} ]]; then
    _log ERROR "TOOLBOX_TOOL_PATH: ${TOOLBOX_TOOL_PATH} NOT FOUND!"
    exit 1
  fi

  local title
  title=${1}

  shift

  toolbox_exec "${title}" "${TOOLBOX_TOOL_PATH}" "$@"
}

