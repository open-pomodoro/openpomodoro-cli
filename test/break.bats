#!/usr/bin/env bats

load test_helper

@test "break executes break hook before starting timer" {
    create_hook "break" 'echo "BREAK_HOOK" >> "$TEST_DIR/hook_log"; exit 1'

    run pomodoro break
    [ "$status" -ne 0 ]

    assert_hook_contains "BREAK_HOOK"
}

@test "break with custom duration parses correctly" {
    create_hook "break" 'echo "BREAK_STARTED" >> "$TEST_DIR/hook_log"; exit 1'

    run pomodoro break "10"
    [ "$status" -ne 0 ]

    assert_hook_contains "BREAK_STARTED"
}

@test "break with invalid duration fails" {
    run pomodoro break "invalid"
    [ "$status" -ne 0 ]
}
