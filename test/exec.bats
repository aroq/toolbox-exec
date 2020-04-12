#!/usr/bin/env bats

@test "exec :: status" {
  run test/test echo "OK"
  [ "$status" -eq 0 ]
  [ "$output" = "OK" ]
}

@test "run :: status" {
  export CMD="toolbox_run"
  run test/test echo "OK"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "OK" ]]
}

@test "exec :: log :: No log level" {
  run test/test echo "OK"
  [[ "$status" -eq 0 ]]
  [[ ! "$output" =~ "echo OK" ]]
}

@test "run :: log :: No log level" {
  export CMD="toolbox_run"
  run test/test echo "OK"
  [[ "$status" -eq 0 ]]
  [[ ! "$output" =~ "echo OK" ]]
}

@test "exec :: log :: TOOLBOX_LOG_LEVEL=\"DEBUG\"" {
  export TOOLBOX_LOG_LEVEL="DEBUG"
  run test/test echo "OK"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Exec" ]]
  [[ "$output" =~ "echo OK" ]]
}

@test "run :: log :: TOOLBOX_LOG_LEVEL=\"DEBUG\"" {
  export TOOLBOX_LOG_LEVEL="DEBUG"
  export CMD="toolbox_run"
  run test/test echo "OK"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Run" ]]
  [[ "$output" =~ "echo OK" ]]
}

@test "exec :: TOOLBOX_BASH_SET_OPTIONS=\"-x\"" {
  export TOOLBOX_LOG_LEVEL="DEBUG"
  export TOOLBOX_BASH_SET_OPTIONS="-x"
  run test/test echo "OK"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "DEBUG" ]]
}


@test "exec :: TOOLBOX_EXEC_LOG_PREFIX is not set" {
  export TOOLBOX_LOG_LEVEL="DEBUG"
  run test/test echo "OK"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "--->" ]]
}

@test "exec :: TOOLBOX_EXEC_LOG_PREFIX=\"\"" {
  export TOOLBOX_LOG_LEVEL="DEBUG"
  export TOOLBOX_EXEC_LOG_PREFIX=""
  run test/test echo "OK"
  [ "$status" -eq 0 ]
  [[ ! "$output" =~ "--->" ]]
}
