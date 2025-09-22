#!/usr/bin/env bats

load test_helper

@test "history shows nothing when no history exists" {
    run pomodoro history
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "history shows completed pomodoros" {
    pomodoro start "First task" --ago 10m
    pomodoro finish
    pomodoro start "Second task" --ago 5m
    pomodoro finish

    run pomodoro history
    [ "$status" -eq 0 ]
    [[ "$output" =~ "First task" ]]
    [[ "$output" =~ "Second task" ]]
}

@test "history limit flag restricts output" {
    pomodoro start "Task 1" --ago 15m
    pomodoro finish
    pomodoro start "Task 2" --ago 10m
    pomodoro finish
    pomodoro start "Task 3" --ago 5m
    pomodoro finish

    run pomodoro history --limit 2
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Task 2" ]]
    [[ "$output" =~ "Task 3" ]]
    [[ ! "$output" =~ "Task 1" ]]
}

@test "history shows timestamps and durations" {
    pomodoro start "Test task" --ago 10m
    pomodoro finish

    run pomodoro history
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Test task" ]]
    [[ "$output" =~ "$(date '+%Y-%m-%d')" ]]
    [[ "$output" =~ "duration=10" ]]
}

@test "history with zero limit shows all entries" {
    pomodoro start "Task 1" --ago 10m
    pomodoro finish
    pomodoro start "Task 2" --ago 5m
    pomodoro finish

    run pomodoro history --limit 0
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Task 1" ]]
    [[ "$output" =~ "Task 2" ]]
}