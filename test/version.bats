#!/usr/bin/env bats

load test_helper

@test "version flag shows version" {
    run pomodoro --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "pomodoro version" ]]
}

@test "version subcommand shows detailed version info" {
    run pomodoro version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "pomodoro version" ]]
}

@test "version subcommand appears in help" {
    run pomodoro --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "version     Print version information" ]]
}