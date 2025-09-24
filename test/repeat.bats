#!/usr/bin/env bats

load test_helper

@test "repeat copies description from last history entry" {
    pomodoro start "Original task" --ago 5m
    pomodoro finish
    run pomodoro repeat
    [ "$status" -eq 0 ]
    assert_file_contains "current" "Original task"
}

@test "repeat copies tags from last history entry" {
    pomodoro start "Task with tags" -t "work,urgent" --ago 5m
    pomodoro finish
    run pomodoro repeat
    [ "$status" -eq 0 ]
    assert_file_contains "current" "work,urgent"
}

@test "repeat uses default duration" {
    pomodoro start "Task" -d 45 --ago 10m
    pomodoro finish
    run pomodoro repeat
    [ "$status" -eq 0 ]
    assert_file_contains "current" "duration=25"
}

@test "repeat creates new timestamp" {
    pomodoro start "Task" --ago 5m
    pomodoro finish
    run pomodoro repeat
    [ "$status" -eq 0 ]
    assert_file_contains "current" "$(date '+%Y-%m-%d')"
}


@test "repeat outputs current pomodoro status" {
    pomodoro start "Repeated task" --ago 5m
    pomodoro finish
    run pomodoro repeat
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Repeated task" ]]
}

@test "repeat with no history fails" {
    run pomodoro repeat
    [ "$status" -ne 0 ]
}
