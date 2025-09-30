#!/usr/bin/env bats

load test_helper

@test "start hook executes when starting pomodoro" {
    create_hook "start" 'echo "START_HOOK_EXECUTED" >> "$TEST_DIR/hook_log"'

    run pomodoro start "Test task"
    assert_success

    assert_hook_contains "START_HOOK_EXECUTED"
}

@test "stop hook executes when finishing pomodoro" {
    create_hook "stop" 'echo "STOP_HOOK_EXECUTED" >> "$TEST_DIR/hook_log"'

    pomodoro start "Test task" --ago 5m
    run pomodoro finish
    assert_success

    assert_hook_contains "STOP_HOOK_EXECUTED"
}

@test "stop hook executes when cancelling pomodoro" {
    create_hook "stop" 'echo "CANCEL_HOOK_EXECUTED" >> "$TEST_DIR/hook_log"'

    pomodoro start "Test task"
    run pomodoro cancel
    assert_success

    assert_hook_contains "CANCEL_HOOK_EXECUTED"
}

@test "stop hook executes when clearing pomodoro" {
    create_hook "stop" 'echo "CLEAR_HOOK_EXECUTED" >> "$TEST_DIR/hook_log"'

    pomodoro start "Test task"
    run pomodoro clear
    assert_success

    assert_hook_contains "CLEAR_HOOK_EXECUTED"
}

@test "start hook executes when repeating pomodoro" {
    pomodoro start "Original task" --ago 5m
    pomodoro finish

    create_hook "start" 'echo "REPEAT_HOOK_EXECUTED" >> "$TEST_DIR/hook_log"'

    run pomodoro repeat
    assert_success

    assert_hook_contains "REPEAT_HOOK_EXECUTED"
}

@test "non-executable hook causes command to fail" {
    mkdir -p "$TEST_DIR/hooks"
    echo 'echo "SHOULD_NOT_RUN" >> "$TEST_DIR/hook_log"' > "$TEST_DIR/hooks/start"

    run pomodoro start "Test task"
    assert_failure

    run test -f "$TEST_DIR/hook_log"
    assert_failure
}

@test "missing hook does not cause error" {
    run pomodoro start "Test task"
    assert_success

    run test -f "$TEST_DIR/hook_log"
    assert_failure
}

@test "hook failure does not prevent command from succeeding" {
    create_hook "start" 'echo "HOOK_RAN" >> "$TEST_DIR/hook_log"; exit 1'

    run pomodoro start "Test task"
    assert_failure

    assert_hook_contains "HOOK_RAN"
}

@test "multiple hooks execute in sequence" {
    create_hook "start" 'echo "START_EXECUTED" >> "$TEST_DIR/hook_log"'
    create_hook "stop" 'echo "STOP_EXECUTED" >> "$TEST_DIR/hook_log"'

    pomodoro start "Test task" --ago 5m
    run pomodoro finish
    assert_success

    assert_hook_contains "START_EXECUTED"
    assert_hook_contains "STOP_EXECUTED"
}

@test "hook receives POMODORO_ID environment variable" {
    create_hook "start" 'echo "ID=$POMODORO_ID" >> "$TEST_DIR/hook_log"'

    run pomodoro start "Test task" --ago 5m
    assert_success

    run grep -o 'ID=....-..-..T..:..:..-..:..' "$TEST_DIR/hook_log"
    assert_success
}

@test "hook receives POMODORO_DIRECTORY environment variable" {
    create_hook "start" 'echo "DIR=$POMODORO_DIRECTORY" >> "$TEST_DIR/hook_log"'

    run pomodoro start "Test task"
    assert_success

    assert_hook_contains "DIR=$TEST_DIR"
}

@test "hook receives POMODORO_COMMAND environment variable" {
    create_hook "start" 'echo "CMD=$POMODORO_COMMAND" >> "$TEST_DIR/hook_log"'

    run pomodoro start "Test task"
    assert_success

    assert_hook_contains "CMD=start"
}

@test "hook receives POMODORO_ARGS environment variable" {
    create_hook "start" 'echo "ARGS=$POMODORO_ARGS" >> "$TEST_DIR/hook_log"'

    run pomodoro start "Test task" --tags "urgent,work" --duration 30
    assert_success

    assert_hook_contains 'ARGS=Test task --tags urgent,work --duration 30'
}

@test "hook can use POMODORO_ID with show command" {
    create_hook "start" 'desc=$(pomodoro --directory "$POMODORO_DIRECTORY" show description "$POMODORO_ID"); echo "DESC=$desc" >> "$TEST_DIR/hook_log"'

    run pomodoro start "My test description"
    assert_success

    assert_hook_contains "DESC=My test description"
}

@test "break hook receives POMODORO_BREAK_DURATION_MINUTES" {
    create_hook "break" 'echo "MINS=$POMODORO_BREAK_DURATION_MINUTES" >> "$TEST_DIR/hook_log"'

    run pomodoro break 15 --wait=false
    assert_success

    assert_hook_contains "MINS=15"
}

@test "break hook receives POMODORO_BREAK_DURATION_SECONDS" {
    create_hook "break" 'echo "SECS=$POMODORO_BREAK_DURATION_SECONDS" >> "$TEST_DIR/hook_log"'

    run pomodoro break 5 --wait=false
    assert_success

    assert_hook_contains "SECS=300"
}

@test "finish --break hook receives break duration" {
    create_hook "break" 'echo "MINS=$POMODORO_BREAK_DURATION_MINUTES SECS=$POMODORO_BREAK_DURATION_SECONDS" >> "$TEST_DIR/hook_log"'

    pomodoro start "Task" --ago 5m
    run pomodoro finish --break=10 --wait=false
    assert_success

    assert_hook_contains "MINS=10 SECS=600"
}
