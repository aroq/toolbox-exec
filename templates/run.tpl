#!/usr/bin/env bash

# Setup variables
{{- if has .task "env" -}}
{{- range $k, $v := .task.env -}}
{{- if $v }}
export {{ $k }}=${ {{- $k }}:-{{ $v }}}
{{- end -}}
{{- end }}
{{ end }}
export TOOLBOX_TOOL_NAME="{{ (ds "task_name" ).name }}"

{{ if has .task "cmd" -}}
export TOOLBOX_TOOL={{ .task.cmd}}
{{ else }}
export TOOLBOX_TOOL="tools/${TOOLBOX_TOOL_NAME}"
{{ end -}}

# Setup tool dirs
{{ if has .task "tool_dirs" -}}
export TOOLBOX_TOOL_DIRS="toolbox,{{ $l :=  reverse .task.tool_dirs | uniq }}{{ join $l "," }}"
{{ end -}}

# Setup files
{{ if has .task "files" -}}
{{ if has .task.files "exec_contexts" -}}
{{- range $context, $files := .task.files.exec_contexts -}}
export TOOLBOX_FILES_{{ $context }}="{{ $l :=  $files | uniq }}{{ join $l "," }}"
{{ end -}}
{{ end -}}
{{ end -}}


# Includes
. "{{ getenv "TOOLBOX_DEPS_DIR" "toolbox/deps" }}/toolbox-utils/includes/init.sh"
. "{{ getenv "TOOLBOX_DEPS_DIR" "toolbox/deps" }}/toolbox-utils/includes/util.sh"
. "{{ getenv "TOOLBOX_DEPS_DIR" "toolbox/deps" }}/toolbox-utils/includes/log.sh"
. "{{ getenv "TOOLBOX_DEPS_DIR" "toolbox/deps" }}/toolbox-exec/includes/exec.sh"

toolbox_exec_wrapper "toolbox_exec_tool" "$@"
