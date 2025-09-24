#!/usr/bin/env bats

load test_helper

@test "finish moves current pomodoro to history" {
    pomodoro start "Work session"
    run pomodoro finish
    [ "$status" -eq 0 ]

    assert_file_empty "current"
    assert_file_contains "history" "Work session"
}

@test "finish records actual elapsed time in history" {
    pomodoro start "Work session" -d 30 --ago 10m
    run pomodoro finish
    [ "$status" -eq 0 ]

    assert_file_contains "history" "Work session"
    assert_file_contains "history" "duration=10"
}

@test "finish appends to existing history" {
    pomodoro start "First task" --ago 5m
    pomodoro finish
    pomodoro start "Second task" --ago 3m
    run pomodoro finish
    [ "$status" -eq 0 ]

    assert_file_contains "history" "First task"
    assert_file_contains "history" "Second task"
}

@test "finish outputs elapsed time" {
    pomodoro start "Test task" --ago 5m
    run pomodoro finish
    [ "$status" -eq 0 ]
    [[ "$output" =~ "5:" ]]
}

@test "finish with no current pomodoro succeeds" {
    run pomodoro finish
    [ "$status" -eq 0 ]
    assert_file_empty "current"
}
