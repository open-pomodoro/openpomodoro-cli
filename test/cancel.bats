#!/usr/bin/env bats

load test_helper

@test "cancel empties current file and removes from history" {
    pomodoro start "Task to cancel"
    run pomodoro cancel
    [ "$status" -eq 0 ]
    assert_file_empty "current"
    assert_file_empty "history"
}

@test "cancel preserves existing history but removes current" {
    pomodoro start "First task" --ago 5m
    pomodoro finish
    pomodoro start "Task to cancel"
    run pomodoro cancel
    [ "$status" -eq 0 ]

    assert_file_contains "history" "First task"
    assert_file_empty "current"
}

@test "cancel with no current pomodoro succeeds" {
    run pomodoro cancel
    [ "$status" -eq 0 ]
    assert_file_empty "current"
}

@test "cancel produces no output" {
    pomodoro start "Test task"
    run pomodoro cancel
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
