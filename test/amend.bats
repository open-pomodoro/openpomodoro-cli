#!/usr/bin/env bats

load test_helper

@test "amend changes description of current pomodoro" {
    pomodoro start "Original task"
    run pomodoro amend "Amended task"
    assert_success
    assert_file_contains "current" "Amended task"
}

@test "amend adds tags to current pomodoro" {
    pomodoro start "Task"
    run pomodoro amend -t "work,urgent"
    assert_success
    assert_file_contains "current" "tags=work,urgent"
}

@test "amend changes duration of current pomodoro" {
    pomodoro start "Task"
    run pomodoro amend -d 45
    assert_success
    assert_file_contains "current" "duration=45"
}


@test "amend creates new current when no current exists" {
    pomodoro start "Task" --ago 5m
    pomodoro finish
    run pomodoro amend "New task"
    assert_success
    assert_file_contains "current" "New task"
}

@test "amend outputs current pomodoro status" {
    pomodoro start "Task"
    run pomodoro amend "Amended task"
    assert_success
    assert_output --partial "Amended task"
}

@test "amend with no arguments succeeds" {
    pomodoro start "Task"
    run pomodoro amend
    assert_success
    assert_file_contains "current" "Task"
}
