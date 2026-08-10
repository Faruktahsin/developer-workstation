#!/usr/bin/env bash

set -Eeuo pipefail

TEST_PASSED=0
TEST_FAILED=0
TOTAL_TESTS=0

assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="${3:-Assertion}"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if [[ "$expected" == "$actual" ]]; then
        TEST_PASSED=$((TEST_PASSED + 1))
        printf "  ✓ PASS: %s\n" "$test_name"
    else
        TEST_FAILED=$((TEST_FAILED + 1))
        printf "  ✗ FAIL: %s (Expected: '%s', Got: '%s')\n" "$test_name" "$expected" "$actual"
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local test_name="${3:-Contains Assertion}"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    case "$haystack" in
        *"$needle"*)
            TEST_PASSED=$((TEST_PASSED + 1))
            printf "  ✓ PASS: %s\n" "$test_name"
            ;;
        *)
            TEST_FAILED=$((TEST_FAILED + 1))
            printf "  ✗ FAIL: %s (Expected haystack to contain '%s')\n" "$test_name" "$needle"
            ;;
    esac
}

assert_exit_code() {
    local expected_code="$1"
    shift
    local cmd=("$@")

    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    local actual_code=0
    set +e
    "${cmd[@]}" >/dev/null 2>&1
    actual_code=$?
    set -e

    if [[ "$expected_code" -eq "$actual_code" ]]; then
        TEST_PASSED=$((TEST_PASSED + 1))
        printf "  ✓ PASS: Exit code %d for '%s'\n" "$expected_code" "${cmd[*]}"
    else
        TEST_FAILED=$((TEST_FAILED + 1))
        printf "  ✗ FAIL: Expected exit code %d, got %d for '%s'\n" "$expected_code" "$actual_code" "${cmd[*]}"
    fi
}

run_test_suite() {
    local suite_name="$1"
    local suite_fn="$2"

    printf "\nRunning Test Suite: \033[1m%s\033[0m\n" "$suite_name"
    printf "========================================\n"
    "$suite_fn"
}

print_summary() {
    printf "\n========================================\n"
    printf "Test Summary: Total: %d | Passed: %d | Failed: %d\n" "$TOTAL_TESTS" "$TEST_PASSED" "$TEST_FAILED"
    if [[ "$TEST_FAILED" -gt 0 ]]; then
        return 1
    fi
    return 0
}
