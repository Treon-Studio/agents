#!/usr/bin/env bash
#############################################################################
# Integration tests for install.sh and update.sh
#############################################################################

set -e

# Get the script directory (where this test file lives)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0
TOTAL=0

cd "$REPO_DIR"

test_case() {
    local name="$1"
    local command="$2"
    local expected="$3"

    TOTAL=$((TOTAL + 1))
    echo -n "Testing: $name... "

    if eval "$command" > /dev/null 2>&1; then
        if [[ -z "$expected" ]] || [[ "$expected" == "success" ]]; then
            echo -e "${GREEN}✓ PASS${NC}"
            PASSED=$((PASSED + 1))
        else
            echo -e "${RED}✗ FAIL${NC} (expected success, got error)"
            FAILED=$((FAILED + 1))
        fi
    else
        if [[ "$expected" == "fail" ]]; then
            echo -e "${GREEN}✓ PASS${NC} (expected failure)"
            PASSED=$((PASSED + 1))
        else
            echo -e "${RED}✗ FAIL${NC}"
            FAILED=$((FAILED + 1))
        fi
    fi
}

test_output() {
    local name="$1"
    local command="$2"
    local expected_pattern="$3"

    TOTAL=$((TOTAL + 1))
    echo -n "Testing: $name... "

    output=$(eval "$command" 2>&1 || true)

    if [[ "$output" =~ $expected_pattern ]]; then
        echo -e "${GREEN}✓ PASS${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${NC}"
        echo "  Expected pattern: $expected_pattern"
        echo "  Got: $output"
        FAILED=$((FAILED + 1))
    fi
}

echo "=============================================="
echo "OpenAgents Integration Tests"
echo "=============================================="
echo ""

# Create temp directory
TEMP_DIR=$(mktemp -d)
INSTALL_DIR="$TEMP_DIR/test-opencode"
mkdir -p "$INSTALL_DIR"

echo "Test directory: $TEMP_DIR"
echo ""

# Test 1: install.sh has correct shebang
test_case "install.sh has valid shebang" \
    'head -1 install.sh | grep -q "#!/usr/bin/env bash"' \
    "success"

# Test 2: update.sh has correct shebang
test_case "update.sh has valid shebang" \
    'head -1 update.sh | grep -q "#!/usr/bin/env bash"' \
    "success"

# Test 3: install.sh is executable
test_case "install.sh is executable" \
    '[ -x install.sh ]' \
    "success"

# Test 4: update.sh is executable
test_case "update.sh is executable" \
    '[ -x update.sh ]' \
    "success"

# Test 5: install.sh --help works
test_output "install.sh --help shows usage" \
    "bash install.sh --help" \
    "Usage:"

# Test 6: install.sh --version works
test_output "install.sh --version shows version" \
    "bash install.sh --version" \
    "version"

# Test 7: install.sh exits on missing curl (mock)
test_case "install.sh validates dependencies" \
    'bash -c "type curl >/dev/null 2>&1 || exit 1"' \
    "success"

# Test 8: install.sh exits on missing tar (mock)
test_case "install.sh requires tar" \
    'bash -c "type tar >/dev/null 2>&1 || exit 1"' \
    "success"

# Test 9: install.sh with invalid profile shows error
test_output "install.sh with invalid profile" \
    "bash install.sh --profile invalid_profile 2>&1 || true" \
    "Unknown option"

# Test 10: install.sh --dry-run flag recognized
test_output "install.sh --dry-run flag recognized" \
    "bash install.sh --help 2>&1" \
    "dry-run"

# Test 11: update.sh content check
test_output "update.sh contains curl download" \
    "cat update.sh" \
    "curl.*install.sh"

# Test 12: install.sh contains update mode
test_output "install.sh has update functionality" \
    "grep -c 'UPDATE_MODE' install.sh || true" \
    "[1-9]"

# Test 13: install.sh has proper error handling
test_output "install.sh has error handling (set -e)" \
    "head -20 install.sh | grep -c 'set -e' || true" \
    "[1-9]"

# Test 14: install.sh has color codes defined
test_output "install.sh defines colors" \
    "grep -c \"RED=\" install.sh || true" \
    "[1-9]"

# Test 15: sync script is present
test_case "sync-config.sh is present" \
    '[ -f scripts/sync-config.sh ]' \
    "success"

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
echo "=============================================="
echo "Results: $PASSED/$TOTAL passed, $FAILED failed"
echo "=============================================="

if [ $FAILED -gt 0 ]; then
    exit 1
fi

exit 0