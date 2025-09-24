#!/usr/bin/env bats

load test_helper

@test "start uses default pomodoro duration from settings" {
    create_settings "default_pomodoro_duration=45"
    pomodoro start "Task with custom default"
    assert_file_contains "current" "duration=45"
}

@test "start uses 25 minutes when no settings file exists" {
    pomodoro start "Task with system default"
    assert_file_contains "current" "duration=25"
}

@test "start explicit duration overrides settings default" {
    create_settings "default_pomodoro_duration=45"
    pomodoro start "Task" -d 30
    assert_file_contains "current" "duration=30"
}

@test "repeat uses default pomodoro duration from settings" {
    create_settings "default_pomodoro_duration=50"
    pomodoro start "Original task" --ago 5m
    pomodoro finish
    run pomodoro repeat
    [ "$status" -eq 0 ]
    assert_file_contains "current" "duration=50"
}

@test "break uses default break duration from settings" {
    create_settings "default_break_duration=10"
    create_hook "break" 'echo "BREAK_HOOK_RAN" >> "$TEST_DIR/hook_log"; exit 1'

    run pomodoro break
    [ "$status" -ne 0 ]
    assert_hook_contains "BREAK_HOOK_RAN"
}

@test "--directory flag uses settings from specified directory" {
    ALT_DIR="$(mktemp -d)"
    create_settings_in "$ALT_DIR/settings" "default_pomodoro_duration=60"

    run "$POMODORO_BIN" --directory "$ALT_DIR" start "Task in alt dir"
    [ "$status" -eq 0 ]

    grep -q "duration=60" "$ALT_DIR/current" || {
        echo "Expected duration=60 in $ALT_DIR/current"
        echo "File contents:"
        cat "$ALT_DIR/current"
        rm -rf "$ALT_DIR"
        return 1
    }

    rm -rf "$ALT_DIR"
}

@test "settings with multiple values are parsed correctly" {
    create_settings \
        "default_pomodoro_duration=35" \
        "default_break_duration=7" \
        "daily_goal=10"

    pomodoro start "Multi-setting task"
    assert_file_contains "current" "duration=35"
}
