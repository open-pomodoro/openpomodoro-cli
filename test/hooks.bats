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
