#!/usr/bin/env bats

load test_helper

@test "history shows nothing when no history exists" {
    run pomodoro history
    assert_success
    refute_output
}

@test "history shows completed pomodoros" {
    pomodoro start "First task" --ago 10m
    pomodoro finish
    pomodoro start "Second task" --ago 5m
    pomodoro finish

    run pomodoro history
    assert_success
    assert_output --partial "First task"
    assert_output --partial "Second task"
}

@test "history limit flag restricts output" {
    pomodoro start "Task 1" --ago 15m
    pomodoro finish
    pomodoro start "Task 2" --ago 10m
    pomodoro finish
    pomodoro start "Task 3" --ago 5m
    pomodoro finish

    run pomodoro history --limit 2
    assert_success
    assert_output --partial "Task 2"
    assert_output --partial "Task 3"
    refute_output --partial "Task 1"
}

@test "history shows timestamps and durations" {
    pomodoro start "Test task" --ago 10m
    pomodoro finish

    run pomodoro history
    assert_success
    assert_output --partial "Test task"
    assert_output --partial "$(date '+%Y-%m-%d')"
    assert_output --partial "duration=10"
}

@test "history with zero limit shows all entries" {
    pomodoro start "Task 1" --ago 10m
    pomodoro finish
    pomodoro start "Task 2" --ago 5m
    pomodoro finish

    run pomodoro history --limit 0
    assert_success
    assert_output --partial "Task 1"
    assert_output --partial "Task 2"
}
