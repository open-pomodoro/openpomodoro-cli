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

@test "settings command shows current configuration" {
    create_settings \
        "default_pomodoro_duration=30" \
        "default_break_duration=10" \
        "daily_goal=8"

    run pomodoro settings
    [ "$status" -eq 0 ]
    [[ "$output" =~ "data_directory=$TEST_DIR" ]]
    [[ "$output" =~ "daily_goal=8" ]]
    [[ "$output" =~ "default_pomodoro_duration=30" ]]
    [[ "$output" =~ "default_break_duration=10" ]]
    [[ "$output" =~ "default_tags=" ]]
}

@test "settings command shows default values when no settings file exists" {
    run pomodoro settings
    [ "$status" -eq 0 ]
    [[ "$output" =~ "data_directory=$TEST_DIR" ]]
    [[ "$output" =~ "daily_goal=0" ]]
    [[ "$output" =~ "default_pomodoro_duration=25" ]]
    [[ "$output" =~ "default_break_duration=5" ]]
    [[ "$output" =~ "default_tags=" ]]
}

@test "settings command JSON output" {
    create_settings \
        "default_pomodoro_duration=40" \
        "daily_goal=12"

    run pomodoro settings --json
    [ "$status" -eq 0 ]
    [[ "$output" =~ "\"data_directory\":" ]]
    [[ "$output" =~ "\"daily_goal\": 12" ]]
    [[ "$output" =~ "\"default_pomodoro_duration\": 40" ]]
    [[ "$output" =~ "\"default_break_duration\": 5" ]]
    [[ "$output" =~ '"default_tags": []' ]]
}


@test "settings command with default_tags displays correctly" {
    create_settings \
        "default_pomodoro_duration=25" \
        "default_tags=work,urgent,project"

    run pomodoro settings
    [ "$status" -eq 0 ]
    [[ "$output" =~ "default_tags=work,urgent,project" ]]

    run pomodoro settings --json
    [ "$status" -eq 0 ]
    [[ "$output" == *'"default_tags": ['* ]]
    [[ "$output" == *'"work"'* ]]
    [[ "$output" == *'"urgent"'* ]]
    [[ "$output" == *'"project"'* ]]
}

@test "settings command handles malformed settings file gracefully" {
    echo "default_pomodoro_duration=30" > "$TEST_DIR/settings"
    echo "invalid_line_without_equals" >> "$TEST_DIR/settings"
    echo "daily_goal=8" >> "$TEST_DIR/settings"

    run pomodoro settings
    [ "$status" -eq 0 ]
    [[ "$output" =~ "default_pomodoro_duration=30" ]]
    [[ "$output" =~ "daily_goal=8" ]]
}

@test "settings command with very large duration values" {
    create_settings \
        "default_pomodoro_duration=999" \
        "default_break_duration=120"

    run pomodoro settings
    [ "$status" -eq 0 ]
    [[ "$output" =~ "default_pomodoro_duration=999" ]]
    [[ "$output" =~ "default_break_duration=120" ]]

    run pomodoro settings --json
    [ "$status" -eq 0 ]
    [[ "$output" =~ "\"default_pomodoro_duration\": 999" ]]
    [[ "$output" =~ "\"default_break_duration\": 120" ]]
}

@test "settings command with negative values" {
    create_settings \
        "default_pomodoro_duration=-5" \
        "daily_goal=-1"

    run pomodoro settings
    [ "$status" -eq 0 ]
    [[ "$output" =~ "default_pomodoro_duration=-5" ]]
    [[ "$output" =~ "daily_goal=-1" ]]
}

@test "settings command short flags work correctly" {
    create_settings "daily_goal=5"

    run pomodoro settings -j
    [ "$status" -eq 0 ]
    [[ "$output" =~ "\"daily_goal\": 5" ]]
}

@test "settings command with empty default_tags value" {
    create_settings \
        "default_pomodoro_duration=25" \
        "default_tags="

    run pomodoro settings
    [ "$status" -eq 0 ]
    [[ "$output" =~ "default_tags=" ]]

    run pomodoro settings --json
    [ "$status" -eq 0 ]
    [[ "$output" == *'"default_tags":'* ]]
}

@test "settings command data_directory path validation" {
    run pomodoro settings
    [ "$status" -eq 0 ]

    data_dir=$(echo "$output" | grep "data_directory=" | cut -d'=' -f2)

    [ "$data_dir" = "$TEST_DIR" ]

    [[ "$data_dir" =~ ^/ ]]
}
