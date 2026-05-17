#!/usr/bin/env bats
#############################################################################
# install.sh tests
#############################################################################

setup() {
    # Create temp directory for each test
    TEMP_DIR="$(mktemp -d)"
    cd "$TEMP_DIR"
}

teardown() {
    # Cleanup
    rm -rf "$TEMP_DIR"
}

@test "install.sh exits on missing curl" {
    # Mock command to simulate curl missing
    function command() {
        if [[ "$2" == "curl" ]]; then return 1; fi
        command "$@"
    }
    run bash -c 'source /dev/stdin < <(sed "s/command -v curl/return 1/" install.sh) 2>&1'
    [[ "$output" == *"curl is required"* ]]
}

@test "install.sh exits on missing tar" {
    run bash -c 'source /dev/stdin < <(sed "s/command -v tar/return 1/" install.sh) 2>&1'
    [[ "$output" == *"tar is required"* ]]
}

@test "install.sh with --help shows usage" {
    run bash -c 'source install.sh && print_usage 2>&1'
    [[ "$output" == *"Usage:"* ]]
}

@test "install.sh --version shows version" {
    run bash -c 'source install.sh && print_version 2>&1'
    [[ "$output" == *"OpenAgents"* ]]
    [[ "$output" == *"version"* ]]
}

@test "parse_source_url extracts tarball URL" {
    load '../tests/bats_helper'
    source "$BATS_TEST_DIRNAME/../install.sh"
    url=$(parse_source_url "Treon-Studio/agents")
    [[ "$url" == *"Treon-Studio/agents"* ]]
    [[ "$url" == *"tarball"* ]]
}

@test "parse_source_url handles custom source" {
    load '../tests/bats_helper'
    source "$BATS_TEST_DIRNAME/../install.sh"
    url=$(parse_source_url "https://github.com/custom/repo")
    [[ "$url" == "https://github.com/custom/repo"* ]]
}

@test "normalize_path handles relative paths" {
    load '../tests/bats_helper'
    source "$BATS_TEST_DIRNAME/../install.sh"
    result=$(normalize_path "some/relative/path")
    # Should return absolute path
    [[ "$result" == /* ]]
}

@test "normalize_path expands tilde" {
    load '../tests/bats_helper'
    source "$BATS_TEST_DIRNAME/../install.sh"
    result=$(normalize_path "~/opencode")
    [[ "$result" == "$HOME"* ]]
}

@test "normalize_path removes trailing slash" {
    load '../tests/bats_helper'
    source "$BATS_TEST_DIRNAME/../install.sh"
    result=$(normalize_path "/some/path/")
    [[ "$result" != */ ]]
}