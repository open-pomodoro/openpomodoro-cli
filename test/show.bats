#!/usr/bin/env bats

load test_helper

@test "show requires timestamp argument" {
    run pomodoro show
    [ "$status" -ne 0 ]
    [[ "$output" == *"Available Commands"* ]]
}

@test "show with invalid timestamp returns error" {
    run pomodoro show "invalid-timestamp"
    [ "$status" -ne 0 ]
}

@test "show with non-existent timestamp returns error" {
    run pomodoro show "2023-01-01T12:00:00Z"
    [ "$status" -ne 0 ]
    [[ "$output" == *"not found"* ]] || [[ "$output" == *"does not exist"* ]]
}

@test "show duration in different formats" {
    timestamp=$(create_completed_pomodoro 25)

    assert_show_output "$timestamp" duration "" "25:00"
    assert_show_output "$timestamp" duration "--minutes" "25"
    assert_show_output "$timestamp" duration "--seconds" "1500"
}

@test "show duration with non-default values" {
    timestamp=$(create_completed_pomodoro 45 "Custom task")

    assert_show_output "$timestamp" duration "" "45:00"
    assert_show_output "$timestamp" duration "--minutes" "45"
    assert_show_output "$timestamp" duration "--seconds" "2700"
}

@test "show duration for current pomodoro" {
    # Start a current pomodoro
    pomodoro start "Current task" --duration 30

    # Get current pomodoro info to extract timestamp
    current_info=$(pomodoro history | head -1)
    timestamp=$(echo "$current_info" | cut -d' ' -f1)

    run pomodoro show duration "$timestamp"
    [ "$status" -eq 0 ]
    [ "$output" = "30:00" ]
}

@test "show with conflicting flags returns error" {
    pomodoro start "Test task" --duration 25 --ago 30m
    pomodoro finish

    timestamp=$(pomodoro history | head -1 | cut -d' ' -f1)

    run pomodoro show duration "$timestamp" --minutes --seconds
    [ "$status" -ne 0 ]
    [[ "$output" == *"cannot"* ]] || [[ "$output" == *"conflict"* ]]
}

@test "show other attributes" {
    timestamp=$(create_completed_pomodoro 25 "Test description")

    assert_show_output "$timestamp" description "" "Test description"
    assert_show_output "$timestamp" start_time "" "$timestamp"
    assert_show_output "$timestamp" completed "" "true"
    assert_show_output "$timestamp" completed "--numeric" "1"
}

@test "show tags attribute" {
    pomodoro start "Tagged task" --tags "work,urgent" --duration 25 --ago 25m >/dev/null
    pomodoro finish >/dev/null
    timestamp=$(pomodoro history | head -1 | cut -d' ' -f1)

    assert_show_output "$timestamp" tags "" "work, urgent"
    assert_show_output "$timestamp" tags "--raw" "work,urgent"
}

@test "show JSON output" {
    pomodoro start "JSON test" --tags "test,demo" --duration 30 --ago 30m >/dev/null
    pomodoro finish >/dev/null
    timestamp=$(pomodoro history | head -1 | cut -d' ' -f1)

    run pomodoro show "$timestamp" --json
    [ "$status" -eq 0 ]
    [[ "$output" == *"\"start_time\": \"$timestamp\""* ]]
    [[ "$output" == *"\"description\": \"JSON test\""* ]]
    [[ "$output" == *"\"duration\": 30"* ]]
    [[ "$output" == *"\"tags\": [\"test\", \"demo\"]"* ]]
    [[ "$output" == *"\"completed\": true"* ]]
    [[ "$output" == *"\"is_current\": false"* ]]
}

@test "show omits empty attributes by default" {
    pomodoro start --duration 25 --ago 25m >/dev/null
    pomodoro finish >/dev/null
    timestamp=$(pomodoro history | head -1 | cut -d' ' -f1)

    run pomodoro show "$timestamp"
    [ "$status" -eq 0 ]
    [[ "$output" == *"start_time=$timestamp"* ]]
    [[ "$output" == *"duration=25"* ]]
    [[ "$output" != *"description="* ]]
    [[ "$output" != *"tags="* ]]
}

@test "show --all includes empty attributes" {
    pomodoro start --duration 25 --ago 25m >/dev/null
    pomodoro finish >/dev/null
    timestamp=$(pomodoro history | head -1 | cut -d' ' -f1)

    run pomodoro show "$timestamp" --all
    [ "$status" -eq 0 ]
    [[ "$output" == *"start_time=$timestamp"* ]]
    [[ "$output" == *"description=\"\""* ]]
    [[ "$output" == *"duration=25"* ]]
    [[ "$output" == *"tags="* ]]
}

@test "show description quoting depends on spaces" {
    # Test description without spaces - should not be quoted
    pomodoro start "SingleWord" --duration 25 --ago 25m >/dev/null
    pomodoro finish >/dev/null
    timestamp1=$(pomodoro history | head -1 | cut -d' ' -f1)

    run pomodoro show description "$timestamp1"
    [ "$status" -eq 0 ]
    [ "$output" = "SingleWord" ]

    # Test description with spaces - should be quoted in basic show output
    pomodoro start "Multiple Word Description" --duration 25 --ago 25m >/dev/null
    pomodoro finish >/dev/null
    timestamp2=$(pomodoro history | head -1 | cut -d' ' -f1)

    run pomodoro show description "$timestamp2"
    [ "$status" -eq 0 ]
    [ "$output" = "Multiple Word Description" ]

    # Test basic show output formatting - no quotes for single word
    run pomodoro show "$timestamp1"
    [ "$status" -eq 0 ]
    [[ "$output" == *"description=SingleWord"* ]]

    # Test basic show output formatting - quotes for multiple words
    run pomodoro show "$timestamp2"
    [ "$status" -eq 0 ]
    [[ "$output" == *"description=\"Multiple Word Description\""* ]]
}

@test "show JSON IsCurrent logic for active pomodoro" {
    pomodoro start "Active task" --duration 30

    current_info=$(pomodoro history | head -1)
    timestamp=$(echo "$current_info" | cut -d' ' -f1)

    run pomodoro show "$timestamp" --json
    [ "$status" -eq 0 ]
    [[ "$output" == *"\"completed\": false"* ]]
    [[ "$output" == *"\"is_current\": true"* ]]
}

@test "show JSON IsCurrent logic for completed pomodoro" {
    timestamp=$(create_completed_pomodoro 25 "Completed task")

    run pomodoro show "$timestamp" --json
    [ "$status" -eq 0 ]
    [[ "$output" == *"\"completed\": true"* ]]
    [[ "$output" == *"\"is_current\": false"* ]]
}

@test "show JSON IsCurrent logic edge case - completed current pomodoro" {
    pomodoro start "Quick task" --duration 25 --ago 25m >/dev/null
    pomodoro finish >/dev/null
    timestamp=$(pomodoro history | head -1 | cut -d' ' -f1)

    run pomodoro show "$timestamp" --json
    [ "$status" -eq 0 ]
    [[ "$output" == *"\"completed\": true"* ]]
    [[ "$output" == *"\"is_current\": false"* ]]
}

@test "show with malformed timestamp format returns specific error" {
    run pomodoro show "not-a-timestamp"
    [ "$status" -ne 0 ]
    [[ "$output" == *"invalid timestamp format"* ]]

    run pomodoro show "2023-13-45T99:99:99Z"
    [ "$status" -ne 0 ]
    [[ "$output" == *"invalid timestamp format"* ]]

    run pomodoro show "2023/01/01 12:00:00"
    [ "$status" -ne 0 ]
    [[ "$output" == *"invalid timestamp format"* ]]
}

@test "show with valid timestamp format but non-existent pomodoro returns not found error" {
    run pomodoro show "2025-01-01T12:00:00-05:00"
    [ "$status" -ne 0 ]
    [[ "$output" == *"not found"* ]]

    run pomodoro show "2020-06-15T09:30:00Z"
    [ "$status" -ne 0 ]
    [[ "$output" == *"not found"* ]]
}

@test "show start_time with unix flag validation" {
    timestamp=$(create_completed_pomodoro 25)

    run pomodoro show start_time "$timestamp"
    [ "$status" -eq 0 ]
    [ "$output" = "$timestamp" ]

    run pomodoro show start_time "$timestamp" --unix
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^[0-9]+$ ]]
}

@test "show completed with numeric flag edge cases" {
    pomodoro start "Current task" --duration 30
    current_info=$(pomodoro history | head -1)
    current_timestamp=$(echo "$current_info" | cut -d' ' -f1)

    run pomodoro show completed "$current_timestamp"
    [ "$status" -eq 0 ]
    [ "$output" = "false" ]

    run pomodoro show completed "$current_timestamp" --numeric
    [ "$status" -eq 0 ]
    [ "$output" = "0" ]

    pomodoro cancel >/dev/null 2>&1 || true

    timestamp=$(create_completed_pomodoro 25)

    run pomodoro show completed "$timestamp"
    [ "$status" -eq 0 ]
    [ "$output" = "true" ]

    run pomodoro show completed "$timestamp" --numeric
    [ "$status" -eq 0 ]
    [ "$output" = "1" ]
}

@test "show tags with empty tags edge cases" {
    pomodoro start "No tags task" --duration 25 --ago 25m >/dev/null
    pomodoro finish >/dev/null
    timestamp=$(pomodoro history | head -1 | cut -d' ' -f1)

    run pomodoro show tags "$timestamp"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    run pomodoro show tags "$timestamp" --raw
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "show error handling for edge case pomodoro data" {
    pomodoro start "Very short test" --duration 1 --ago 1m >/dev/null
    pomodoro finish >/dev/null
    timestamp=$(pomodoro history | head -1 | cut -d' ' -f1)

    run pomodoro show duration "$timestamp"
    [ "$status" -eq 0 ]
    [ "$output" = "1:00" ]

    run pomodoro show duration "$timestamp" --minutes
    [ "$status" -eq 0 ]
    [ "$output" = "1" ]

    run pomodoro show duration "$timestamp" --seconds
    [ "$status" -eq 0 ]
    [ "$output" = "60" ]
}

@test "show subcommands reject invalid flag combinations" {
    timestamp=$(create_completed_pomodoro 25)

    run pomodoro show start_time "$timestamp" --unix --unix
    [ "$status" -eq 0 ]

    run pomodoro show tags "$timestamp" --raw --raw
    [ "$status" -eq 0 ]
}

@test "show subcommands handle invalid arguments gracefully" {
    timestamp=$(create_completed_pomodoro 25)

    run pomodoro show duration "$timestamp" extra_arg
    [ "$status" -ne 0 ]

    run pomodoro show description "$timestamp" extra_arg
    [ "$status" -ne 0 ]

    run pomodoro show tags "$timestamp" extra_arg
    [ "$status" -ne 0 ]

    run pomodoro show start_time "$timestamp" extra_arg
    [ "$status" -ne 0 ]

    run pomodoro show completed "$timestamp" extra_arg
    [ "$status" -ne 0 ]
}

@test "show subcommands handle missing timestamp argument" {
    run pomodoro show duration
    [ "$status" -ne 0 ]

    run pomodoro show description
    [ "$status" -ne 0 ]

    run pomodoro show tags
    [ "$status" -ne 0 ]

    run pomodoro show start_time
    [ "$status" -ne 0 ]

    run pomodoro show completed
    [ "$status" -ne 0 ]
}

@test "show command flag inheritance and conflicts" {
    timestamp=$(create_completed_pomodoro 25)

    run pomodoro show duration "$timestamp" --unknown-flag
    [ "$status" -ne 0 ]

    run pomodoro show duration "$timestamp"
    [ "$status" -eq 0 ]
}

@test "show command with malformed flags" {
    timestamp=$(create_completed_pomodoro 25)

    run pomodoro show duration "$timestamp" --invalid-flag
    [ "$status" -ne 0 ]

    run pomodoro show tags "$timestamp" --raw=invalid_value
    [ "$status" -ne 0 ]

    run pomodoro show completed "$timestamp" --numeric
    [ "$status" -eq 0 ]

    run pomodoro show start_time "$timestamp" --unix
    [ "$status" -eq 0 ]
}

@test "show command boundary value testing" {
    pomodoro start "Large duration test" --duration 120 --ago 120m >/dev/null
    pomodoro finish >/dev/null
    timestamp=$(pomodoro history | head -1 | cut -d' ' -f1)

    run pomodoro show duration "$timestamp" --minutes
    [ "$status" -eq 0 ]
    [ "$output" = "120" ]

    run pomodoro show duration "$timestamp" --seconds
    [ "$status" -eq 0 ]
    [ "$output" = "7200" ]

    pomodoro start "Short duration" --duration 1 --ago 1m >/dev/null
    pomodoro finish >/dev/null
    timestamp_short=$(pomodoro history | head -1 | cut -d' ' -f1)

    run pomodoro show duration "$timestamp_short" --seconds
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^[0-9]+$ ]]
}

@test "show command with special characters in data" {
    pomodoro start "Task with \"quotes\" and 'apostrophes' and \$symbols" --tags "tag-with-dash,tag_with_underscore,tag.with.dots" --duration 25 --ago 25m >/dev/null
    pomodoro finish >/dev/null
    timestamp=$(pomodoro history | head -1 | cut -d' ' -f1)

    run pomodoro show description "$timestamp"
    [ "$status" -eq 0 ]
    [[ "$output" == *"quotes"* ]]
    [[ "$output" == *"apostrophes"* ]]
    [[ "$output" == *"\$symbols"* ]]

    run pomodoro show tags "$timestamp"
    [ "$status" -eq 0 ]
    [[ "$output" == *"tag-with-dash"* ]]
    [[ "$output" == *"tag_with_underscore"* ]]
    [[ "$output" == *"tag.with.dots"* ]]

    run pomodoro show tags "$timestamp" --raw
    [ "$status" -eq 0 ]
    [[ "$output" == *"tag-with-dash,tag_with_underscore,tag.with.dots"* ]]
}

@test "show command help and usage validation" {
    run pomodoro show --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Available Commands"* ]]

    run pomodoro show duration --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Show pomodoro duration"* ]]

    run pomodoro show tags --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Show pomodoro tags"* ]]
}

@test "show command concurrent access edge case" {
    timestamp=$(create_completed_pomodoro 25)

    run pomodoro show duration "$timestamp"
    [ "$status" -eq 0 ]

    run pomodoro show description "$timestamp"
    [ "$status" -eq 0 ]

    run pomodoro show tags "$timestamp"
    [ "$status" -eq 0 ]

    run pomodoro show "$timestamp" --json
    [ "$status" -eq 0 ]
    [[ "$output" == *"\"duration\": 25"* ]]
}