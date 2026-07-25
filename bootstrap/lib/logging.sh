#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

log_info() {
    printf "${BLUE}ℹ %s${RESET}\n" "$1"
}

log_success() {
    printf "${GREEN}✓ %s${RESET}\n" "$1"
}

log_warning() {
    printf "${YELLOW}⚠ %s${RESET}\n" "$1"
}

log_error() {
    printf "${RED}✗ %s${RESET}\n" "$1"
}