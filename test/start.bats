#!/usr/bin/env bats

load test_helper

@test "start creates current file" {
    run pomodoro start
    assert_success
    assert_file_exists "current"
}

@test "start with description writes description to current file" {
    run pomodoro start "Important work"
    assert_success
    assert_file_contains "current" 'description="Important work"'
}

@test "start with tags writes tags to current file" {
    run pomodoro start -t "work,urgent"
    assert_success
    assert_file_contains "current" 'tags=work,urgent'
}

@test "start with custom duration writes duration to current file" {
    run pomodoro start --duration 30
    assert_success
    assert_file_contains "current" 'duration=30'
}


@test "start writes timestamp to current file" {
    run pomodoro start
    assert_success
    assert_file_contains "current" "$(date '+%Y-%m-%d')"
}

@test "start replaces existing current pomodoro" {
    pomodoro start "First task"
    run pomodoro start "Second task"
    assert_success
    assert_file_contains "current" "Second task"
    run grep -q "First task" "$TEST_DIR/current"
    assert_failure
}

@test "start outputs current pomodoro status" {
    run pomodoro start "Test task"
    assert_success
    assert_output --partial "Test task"
}
