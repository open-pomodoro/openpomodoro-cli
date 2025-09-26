#!/usr/bin/env bats

load test_helper

@test "root command shows help when no subcommand provided" {
    run pomodoro

    [ "$status" -eq 0 ]
    [[ "$output" =~ "A simple Pomodoro command-line client" ]]
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "Available Commands:" ]]
}

@test "root command --help produces same output as no subcommand" {
    run pomodoro
    no_subcommand_output="$output"

    run pomodoro --help
    help_flag_output="$output"

    [ "$no_subcommand_output" = "$help_flag_output" ]
}

@test "root command help subcommand shows help output" {
    run pomodoro help

    [ "$status" -eq 0 ]
    [[ "$output" =~ "A simple Pomodoro command-line client" ]]
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "Available Commands:" ]]
}