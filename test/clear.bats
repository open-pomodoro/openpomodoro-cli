#!/usr/bin/env bats

load test_helper

@test "clear empties current file" {
    pomodoro start "Work session"
    run pomodoro clear
    [ "$status" -eq 0 ]
    assert_file_empty "current"
}

@test "clear does not affect history" {
    pomodoro start "First task" --ago 5m
    pomodoro finish
    pomodoro start "Second task"
    run pomodoro clear
    [ "$status" -eq 0 ]

    assert_file_contains "history" "First task"
    assert_file_empty "current"
}

@test "clear with no current pomodoro succeeds" {
    run pomodoro clear
    [ "$status" -eq 0 ]
    assert_file_empty "current"
}

@test "clear produces no output" {
    pomodoro start "Test task"
    run pomodoro clear
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

