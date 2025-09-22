#!/usr/bin/env bash

export POMODORO_BIN="${BATS_TEST_DIRNAME}/../main.go"

setup() {
    export TEST_DIR="$(mktemp -d)"
}

teardown() {
    rm -rf "$TEST_DIR"
}

pomodoro() {
    go run "$POMODORO_BIN" --directory "$TEST_DIR" "$@"
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