#!/usr/bin/env bats

load test_helper

@test "root command shows help when no subcommand provided" {
    run pomodoro

    [ "$status" -eq 0 ]
    [[ "$output" =~ "A simple Pomodoro command-line client" ]]
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "pomodoro [command]" ]]
}

@test "help output includes available commands section" {
    run pomodoro

    [ "$status" -eq 0 ]
    [[ "$output" =~ "Available Commands:" ]]
}

@test "help output lists expected core commands" {
    run pomodoro

    [ "$status" -eq 0 ]
    [[ "$output" =~ "start".*"Start a new Pomodoro" ]]
    [[ "$output" =~ "status".*"Show the status of the current Pomodoro" ]]
    [[ "$output" =~ "finish".*"Finish the current Pomodoro" ]]
    [[ "$output" =~ "cancel".*"Cancel the current Pomodoro" ]]
    [[ "$output" =~ "clear".*"Clear the current Pomodoro" ]]
    [[ "$output" =~ "break".*"Take a break" ]]
    [[ "$output" =~ "history".*"Show Pomodoro history" ]]
    [[ "$output" =~ "repeat".*"Repeat the last Pomodoro" ]]
    [[ "$output" =~ "version".*"Print version information" ]]
}

@test "help output includes flags section" {
    run pomodoro

    [ "$status" -eq 0 ]
    [[ "$output" =~ "Flags:" ]]
    [[ "$output" =~ "--directory".*"directory to read/write Open Pomodoro data" ]]
    [[ "$output" =~ "-f, --format".*"format to display Pomodoros in" ]]
    [[ "$output" =~ "-h, --help".*"help for pomodoro" ]]
    [[ "$output" =~ "-v, --version".*"version for pomodoro" ]]
    [[ "$output" =~ "-w, --wait".*"wait for the Pomodoro to end before exiting" ]]
}

@test "help output includes usage instructions" {
    run pomodoro

    [ "$status" -eq 0 ]
    [[ "$output" =~ "Use \"pomodoro [command] --help\" for more information about a command" ]]
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