#!/usr/bin/env bash
#############################################################################
# bats_helper.bash - Common functions for BATS tests
#############################################################################

# Load install.sh functions for testing
load_install_sh() {
    local install_sh_path="${BATS_TEST_DIRNAME}/../install.sh"
    if [ -f "$install_sh_path" ]; then
        source "$install_sh_path"
    fi
}

# Mock git commands for testing
mock_git() {
    cat > /tmp/mock-git.sh << 'MOCKEOF'
#!/usr/bin/env bash
case "$1" in
    clone)
        mkdir -p "$3"
        echo "Mock git clone: $@"
        ;;
    pull)
        echo "Mock git pull: $@"
        ;;
    fetch)
        echo "Mock git fetch: $@"
        ;;
    log)
        echo "Mock git log commit123"
        ;;
    rev-parse)
        if [ "$2" = "HEAD" ]; then
            echo "abc123"
        fi
        ;;
esac
MOCKEOF
    chmod +x /tmp/mock-git.sh
}

# Cleanup mocks
cleanup_mocks() {
    rm -f /tmp/mock-git.sh
}

# Assert file exists
assert_file_exists() {
    local file="$1"
    if [ ! -f "$file" ]; then
        fail "File does not exist: $file"
    fi
}

# Assert directory exists
assert_dir_exists() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        fail "Directory does not exist: $dir"
    fi
}

# Assert string contains substring
assert_contains() {
    local string="$1"
    local substring="$2"
    if [[ ! "$string" =~ $substring ]]; then
        fail "String does not contain: $substring"
    fi
}

# Assert strings are equal
assert_equal() {
    local expected="$1"
    local actual="$2"
    if [ "$expected" != "$actual" ]; then
        fail "Expected: $expected, Got: $actual"
    fi
}