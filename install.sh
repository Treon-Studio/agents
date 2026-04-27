#!/usr/bin/env bash

#############################################################################
# OpenAgents Installer
# Installs .opencode configuration from Treon-Studio/agents
#
# Usage:
#   Interactive:
#     curl -fsSL ... | bash
#   Non-interactive (profile):
#     curl -fsSL ... | bash -s full
#     curl -fsSL ... | bash -s essential
#     curl -fsSL ... | bash -s developer
#
#   With custom install dir:
#     curl -fsSL ... | bash -s full --install-dir ~/my-agents
#############################################################################

set -e

OWNER="Treon-Studio"
REPO="agents"
BRANCH="${AGENTS_BRANCH:-main}"
INSTALL_DIR="${AGENTS_INSTALL_DIR:-.opencode}"
CUSTOM_INSTALL_DIR=""
PROFILE=""
NON_INTERACTIVE=false

TMPDIR=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_header() {
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║           OpenAgents Installer — Treon Studio                  ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error()   { echo -e "${RED}✗${NC} $1"; }
print_info()    { echo -e "${BLUE}ℹ${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_step()    { echo -e "\n${MAGENTA}${BOLD}▶${NC} $1\n"; }

#############################################################################
# Platform & Dependency Checks
#############################################################################

check_bash_version() {
    local major="${BASH_VERSION%%.*}"
    if [ "$major" -lt 3 ]; then
        echo "Error: Bash 3.2+ required (you have $BASH_VERSION)"
        exit 1
    fi
}

check_deps() {
    print_step "Checking dependencies..."
    if ! command -v curl &>/dev/null; then
        print_error "curl is required but not installed"
        exit 1
    fi
    if ! command -v tar &>/dev/null; then
        print_error "tar is required but not installed"
        exit 1
    fi
    print_success "Dependencies OK"
}

#############################################################################
# Path Utilities
#############################################################################

normalize_path() {
    local p="$1"
    # Expand tilde
    if [[ "$p" == ~* ]]; then
        p="${HOME}${p:1}"
    fi
    # Convert backslashes
    p="${p//\\//}"
    # Remove trailing slash
    p="${p%/}"
    # Make absolute if relative
    if [[ ! "$p" = /* ]] && [[ ! "$p" =~ ^[A-Za-z]: ]]; then
        p="$(pwd)/${p}"
    fi
    echo "$p"
}

#############################################################################
# Profile Definitions (plain text for bash 3.2 compat)
#############################################################################

get_profile_patterns() {
    case "$1" in
        minimal)
            echo ".opencode/agent/core/
.opencode/config/
.opencode/context/core/essential-patterns.md
.opencode/context/core/navigation.md
.opencode/context/core/system/
.opencode/context/core/standards/"
            ;;
        essential)
            echo ".opencode/agent/core/
.opencode/agent/subagents/core/
.opencode/agent/subagents/code/
.opencode/config/
.opencode/context/core/
.opencode/context/project/
.opencode/context/project-intelligence/
.opencode/command/"
            ;;
        developer)
            echo ".opencode/agent/core/
.opencode/agent/subagents/code/
.opencode/agent/subagents/development/
.opencode/agent/subagents/frontend-expert.md
.opencode/agent/subagents/mobile-expert.md
.opencode/agent/subagents/performance-auditor.md
.opencode/config/
.opencode/context/core/
.opencode/context/development/
.opencode/context/ui/
.opencode/context/project/
.opencode/context/project-intelligence/
.opencode/command/
.opencode/skills/"
            ;;
        content)
            echo ".opencode/agent/content/
.opencode/agent/core/
.opencode/config/
.opencode/context/core/
.opencode/context/ui/
.opencode/context/project/
.opencode/context/project-intelligence/"
            ;;
        full|*)
            echo ".opencode/"
            ;;
    esac
}

get_profile_desc() {
    case "$1" in
        minimal)    echo "Minimal — core agents + basic standards" ;;
        essential)  echo "Essential — core agents, contexts, commands" ;;
        developer)  echo "Developer — dev tools, subagents, skills" ;;
        content)    echo "Content — SEO & content agents, UI context" ;;
        full)       echo "Full — everything" ;;
    esac
}

#############################################################################
# File Filtering
#############################################################################

file_matches_profile() {
    local file="$1"
    local patterns="$2"

    while IFS= read -r pat; do
        [ -z "$pat" ] && continue
        # Directory prefix match (pattern ends with /)
        if [[ "$pat" == */ ]]; then
            if [[ "$file" == "$pat"* ]]; then
                return 0
            fi
        else
            # Exact file match
            if [[ "$file" == "$pat" ]]; then
                return 0
            fi
        fi
    done <<< "$patterns"
    return 1
}

#############################################################################
# Download & Extract
#############################################################################

use_local_source() {
    # Check if running inside the repo with .opencode locally available
    if [ -d ".opencode" ] && [ -f ".opencode/config/agent-metadata.json" ]; then
        return 0
    fi
    return 1
}

download_and_extract() {
    print_step "Downloading repository archive..."

    TMPDIR=$(mktemp -d)
    local tarfile="${TMPDIR}/repo.tar.gz"
    local url="https://github.com/${OWNER}/${REPO}/archive/refs/heads/${BRANCH}.tar.gz"

    if ! curl -fsSL "$url" -o "$tarfile"; then
        print_error "Failed to download archive from $url"
        print_info "Make sure the repository exists and is public."
        exit 1
    fi

    # Validate it's actually a gzip file, not a 404 HTML page
    if ! file "$tarfile" | grep -qi gzip; then
        print_error "Downloaded file is not a valid archive (repo may be empty or private)"
        print_info "URL: $url"
        exit 1
    fi

    print_success "Archive downloaded"
    print_step "Extracting..."

    if ! tar -xzf "$tarfile" -C "$TMPDIR"; then
        print_error "Failed to extract archive"
        exit 1
    fi

    print_success "Extracted"
}

#############################################################################
# Installation
#############################################################################

perform_install() {
    local patterns
    patterns=$(get_profile_patterns "$PROFILE")

    local opencode_src=""

    if use_local_source; then
        print_info "Using local .opencode directory"
        opencode_src="$(pwd)/.opencode"
    else
        local src_dir="${TMPDIR}/${REPO}-${BRANCH}"
        if [ ! -d "$src_dir" ]; then
            src_dir=$(find "$TMPDIR" -maxdepth 1 -type d | grep -v "^${TMPDIR}$" | head -n 1)
        fi
        opencode_src="${src_dir}/.opencode"
        if [ ! -d "$opencode_src" ]; then
            print_error ".opencode directory not found"
            exit 1
        fi
    fi

    print_step "Installing profile: ${BOLD}${PROFILE}${NC}"
    print_info "Target: ${INSTALL_DIR}"

    mkdir -p "$INSTALL_DIR"

    local installed=0 skipped=0 failed=0

    # Walk through source .opencode and copy matching files
    local all_files
    all_files=$(find "$opencode_src" -type f | sed "s|${opencode_src}/||")

    while IFS= read -r rel; do
        [ -z "$rel" ] && continue
        local src_file="${opencode_src}/${rel}"
        local dest_file="${INSTALL_DIR}/${rel}"

        if ! file_matches_profile ".opencode/${rel}" "$patterns"; then
            continue
        fi

        # Skip if exists (non-interactive) or ask (interactive)
        if [ -f "$dest_file" ]; then
            if [ "$NON_INTERACTIVE" = true ]; then
                print_info "Skipped (exists): ${rel}"
                skipped=$((skipped + 1))
                continue
            else
                echo -n "Overwrite ${rel}? [y/N]: "
                read -r ans
                if [[ ! "$ans" =~ ^[Yy]$ ]]; then
                    skipped=$((skipped + 1))
                    continue
                fi
            fi
        fi

        mkdir -p "$(dirname "$dest_file")"
        if cp "$src_file" "$dest_file"; then
            installed=$((installed + 1))
        else
            print_error "Failed: ${rel}"
            failed=$((failed + 1))
        fi
    done <<< "$all_files"

    echo ""
    print_success "Installation complete!"
    echo -e "  Installed: ${GREEN}${installed}${NC}"
    [ $skipped -gt 0 ] && echo -e "  Skipped:   ${CYAN}${skipped}${NC}"
    [ $failed -gt 0 ]  && echo -e "  Failed:    ${RED}${failed}${NC}"
}

#############################################################################
# Interactive Mode
#############################################################################

show_location_menu() {
    clear 2>/dev/null || true
    print_header
    echo -e "${BOLD}Choose installation location:${NC}\n"
    echo -e "  ${GREEN}1) Local${NC}  — .opencode/ in current directory"
    echo -e "  ${BLUE}2) Global${NC} — ~/.config/opencode/"
    echo -e "  ${MAGENTA}3) Custom${NC} — enter path"
    echo "  4) Exit"
    echo ""
    read -r -p "Choice [1-4]: " loc
    case $loc in
        1) INSTALL_DIR=".opencode" ;;
        2) INSTALL_DIR="${HOME}/.config/opencode" ;;
        3)
            read -r -p "Enter path: " p
            INSTALL_DIR=$(normalize_path "$p")
            ;;
        4) exit 0 ;;
        *) show_location_menu ;;
    esac
}

show_profile_menu() {
    clear 2>/dev/null || true
    print_header
    echo -e "${BOLD}Choose profile:${NC}\n"
    local profiles="minimal essential developer content full"
    local i=1
    for p in $profiles; do
        printf "  %s) %-12s — %s\n" "$i" "$p" "$(get_profile_desc "$p")"
        i=$((i + 1))
    done
    echo "  6) Exit"
    echo ""
    read -r -p "Choice [1-6]: " sel
    case $sel in
        1) PROFILE="minimal" ;;
        2) PROFILE="essential" ;;
        3) PROFILE="developer" ;;
        4) PROFILE="content" ;;
        5) PROFILE="full" ;;
        6) exit 0 ;;
        *) show_profile_menu ;;
    esac
}

#############################################################################
# Cleanup
#############################################################################

cleanup() {
    if [ -n "$TMPDIR" ] && [ -d "$TMPDIR" ]; then
        rm -rf "$TMPDIR"
    fi
}

trap cleanup EXIT INT TERM

#############################################################################
# Main
#############################################################################

usage() {
    print_header
    echo "Usage: $0 [PROFILE] [OPTIONS]"
    echo ""
    echo -e "${BOLD}Profiles:${NC}"
    echo "  minimal      Core agents + basic standards"
    echo "  essential    Core agents, contexts, commands"
    echo "  developer    Development tools, subagents, skills"
    echo "  content      SEO & content agents, UI context"
    echo "  full         Everything (default)"
    echo ""
    echo -e "${BOLD}Options:${NC}"
    echo "  --install-dir PATH   Custom installation directory"
    echo "  --help, -h           Show this help"
    echo ""
    echo -e "${BOLD}Examples:${NC}"
    echo "  $0                          # Interactive mode"
    echo "  $0 full                     # Install everything"
    echo "  $0 developer                # Install dev profile"
    echo "  $0 essential --install-dir ~/.config/opencode"
    echo ""
    echo -e "${BOLD}One-liner:${NC}"
    echo "  curl -fsSL https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}/install.sh | bash -s full"
    exit 0
}

main() {
    check_bash_version

    # Parse arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            --install-dir)
                CUSTOM_INSTALL_DIR="$2"
                shift 2
                ;;
            --install-dir=*)
                CUSTOM_INSTALL_DIR="${1#*=}"
                shift
                ;;
            --help|-h|help)
                usage
                ;;
            minimal|essential|developer|content|full)
                PROFILE="$1"
                NON_INTERACTIVE=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                echo "Run '$0 --help' for usage"
                exit 1
                ;;
        esac
    done

    # Apply custom install dir
    if [ -n "$CUSTOM_INSTALL_DIR" ]; then
        INSTALL_DIR=$(normalize_path "$CUSTOM_INSTALL_DIR")
    fi

    check_deps

    if ! use_local_source; then
        download_and_extract
    fi

    if [ "$NON_INTERACTIVE" = true ]; then
        # Profile already set
        perform_install
    else
        # Interactive
        show_location_menu
        show_profile_menu
        perform_install
    fi

    echo ""
    print_info "Installed to: ${CYAN}${INSTALL_DIR}${NC}"
    print_info "Repo: https://github.com/${OWNER}/${REPO}"
}

main "$@"
