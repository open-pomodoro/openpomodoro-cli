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