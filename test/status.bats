#!/usr/bin/env bats

load test_helper

@test "status shows nothing when no current pomodoro" {
    run pomodoro status
    assert_success
    refute_output
}

@test "status shows current pomodoro description" {
    pomodoro start "Current task"
    run pomodoro status
    assert_success
    assert_output --partial "Current task"
}

@test "status shows current pomodoro tags" {
    pomodoro start "Task" -t "work,urgent"
    run pomodoro status
    assert_success
    assert_output --partial "work, urgent"
}

@test "status shows remaining time for active pomodoro" {
    pomodoro start "Task" --ago 5m
    run pomodoro status
    assert_success
    assert_output --regexp "(19:|20:)"
}

@test "status shows exclamation for overdue pomodoro" {
    pomodoro start "Task" --ago 30m
    run pomodoro status
    assert_success
    assert_output --partial "❗️"
}
