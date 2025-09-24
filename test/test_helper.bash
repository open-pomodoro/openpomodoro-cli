#!/usr/bin/env bash

export POMODORO_BIN="${BATS_TEST_DIRNAME}/../pomodoro"

setup() {
    export TEST_DIR="$(mktemp -d)"
}

teardown() {
    rm -rf "$TEST_DIR"
}

pomodoro() {
    "$POMODORO_BIN" --directory "$TEST_DIR" "$@"
}

assert_file_exists() {
    local file="$TEST_DIR/$1"
    [ -f "$file" ] || {
        echo "File $file does not exist"
        return 1
    }
}

assert_file_contains() {
    local file="$TEST_DIR/$1"
    local content="$2"
    grep -q "$content" "$file" || {
        echo "File $file does not contain: $content"
        echo "File contents:"
        cat "$file"
        return 1
    }
}

assert_file_empty() {
    local file="$TEST_DIR/$1"
    [ ! -s "$file" ] || {
        echo "File $file is not empty"
        echo "Contents:"
        cat "$file"
        return 1
    }
}

create_hook() {
    local hook_name="$1"
    local hook_content="$2"

    mkdir -p "$TEST_DIR/hooks"
    cat > "$TEST_DIR/hooks/$hook_name" << EOF
#!/bin/bash
$hook_content
EOF
    chmod +x "$TEST_DIR/hooks/$hook_name"
}

assert_hook_executed() {
    [ -f "$TEST_DIR/hook_log" ] || {
        echo "Hook log file not found"
        return 1
    }
}

assert_hook_contains() {
    assert_hook_executed
    grep -q "$1" "$TEST_DIR/hook_log" || {
        echo "Hook log does not contain: $1"
        echo "Hook log contents:"
        cat "$TEST_DIR/hook_log"
        return 1
    }
}

create_settings() {
    local settings_file="$TEST_DIR/settings"
    local setting_line

    for setting_line in "$@"; do
        echo "$setting_line" >> "$settings_file"
    done
}

create_settings_in() {
    local settings_file="$1"
    shift
    local setting_line

    > "$settings_file"

    for setting_line in "$@"; do
        echo "$setting_line" >> "$settings_file"
    done
}
