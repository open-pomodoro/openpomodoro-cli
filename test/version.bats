#!/usr/bin/env bats

load test_helper

@test "version flag shows version" {
    run pomodoro --version
    assert_success
    assert_output --regexp "pomodoro version"
}

@test "version subcommand shows detailed version info" {
    run pomodoro version
    assert_success
    assert_output --regexp "pomodoro version"
}

@test "version subcommand appears in help" {
    run pomodoro --help
    assert_success
    assert_output --regexp "version     Print version information"
}