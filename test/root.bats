#!/usr/bin/env bats

load test_helper

@test "root command shows help when no subcommand provided" {
    run pomodoro

    assert_success
    assert_output --partial "A simple Pomodoro command-line client"
    assert_output --partial "Usage:"
    assert_output --partial "Available Commands:"
}

@test "root command --help produces same output as no subcommand" {
    run pomodoro
    no_subcommand_output="$output"

    run pomodoro --help
    help_flag_output="$output"

    assert_equal "$no_subcommand_output" "$help_flag_output"
}

@test "root command help subcommand shows help output" {
    run pomodoro help

    assert_success
    assert_output --partial "A simple Pomodoro command-line client"
    assert_output --partial "Usage:"
    assert_output --partial "Available Commands:"
}