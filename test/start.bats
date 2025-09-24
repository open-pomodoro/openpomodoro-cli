#!/usr/bin/env bats

load test_helper

@test "start creates current file" {
    run pomodoro start
    [ "$status" -eq 0 ]
    assert_file_exists "current"
}

@test "start with description writes description to current file" {
    run pomodoro start "Important work"
    [ "$status" -eq 0 ]
    assert_file_contains "current" 'description="Important work"'
}

@test "start with tags writes tags to current file" {
    run pomodoro start -t "work,urgent"
    [ "$status" -eq 0 ]
    assert_file_contains "current" 'tags=work,urgent'
}

@test "start with custom duration writes duration to current file" {
    run pomodoro start --duration 30
    [ "$status" -eq 0 ]
    assert_file_contains "current" 'duration=30'
}


@test "start writes timestamp to current file" {
    run pomodoro start
    [ "$status" -eq 0 ]
    assert_file_contains "current" "$(date '+%Y-%m-%d')"
}

@test "start replaces existing current pomodoro" {
    pomodoro start "First task"
    run pomodoro start "Second task"
    [ "$status" -eq 0 ]
    assert_file_contains "current" "Second task"
    ! grep -q "First task" "$TEST_DIR/current"
}

@test "start outputs current pomodoro status" {
    run pomodoro start "Test task"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Test task" ]]
}
