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
UPDATE_MODE=false
DRY_RUN=false
BACKUP_DIR=""
SOURCE_URL=""

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

parse_source_url() {
    local input="$1"
    if [ -z "$input" ]; then
        echo "https://github.com/${OWNER}/${REPO}/archive/refs/heads/${BRANCH}.tar.gz"
        return
    fi

    # Handle GitHub URLs
    if [[ "$input" =~ github\.com/([^/]+)/([^/]+) ]]; then
        local url_owner="${BASH_REMATCH[1]}"
        local url_repo="${BASH_REMATCH[2]}"
        # Strip .git if present
        url_repo="${url_repo%.git}"
        echo "https://github.com/${url_owner}/${url_repo}/archive/refs/heads/${BRANCH}.tar.gz"
    else
        # Assume it's a full tar.gz URL
        echo "$input"
    fi
}

#############################################################################
# Update Functions
#############################################################################

get_file_checksum() {
    local file="$1"
    if command -v shasum &>/dev/null; then
        shasum -a 256 "$file" | cut -d' ' -f1
    elif command -v sha256sum &>/dev/null; then
        sha256sum "$file" | cut -d' ' -f1
    else
        # Fallback: use openssl
        openssl sha -sha256 "$file" | sed 's/.*= //'
    fi
}

download_checksums() {
    local url="$1"
    local checksum_url="${url%.tar.gz}/checksums.txt"

    # Try to fetch checksums from root of repo
    curl -fsSL "${url%/*/*}/checksums.txt" 2>/dev/null && return 0

    # If no checksums file, generate checksums on-the-fly from download
    local tmp_checksum=$(mktemp)
    curl -fsSL "$url" -o "$tmp_checksum"
    if [ -f "$tmp_checksum" ]; then
        tar -tzf "$tmp_checksum" 2>/dev/null | while read -r f; do
            echo "missing  $f"
        done
        rm -f "$tmp_checksum"
        return 0
    fi
    rm -f "$tmp_checksum"
    return 1
}

get_remote_file_list() {
    local src_dir="$1"
    find "$src_dir" -type f -name "*.md" -o -type f ! -name "*.md" 2>/dev/null | sed "s|${src_dir}/||" | sort
}

get_local_file_list() {
    local install_dir="$1"
    find "$install_dir" -type f 2>/dev/null | sed "s|${install_dir}/||" | sort
}

compute_checksums_from_tar() {
    local tarfile="$1"
    local tmp_dir=$(mktemp -d)
    tar -xzf "$tarfile" -C "$tmp_dir"
    local src_dir=$(find "$tmp_dir" -maxdepth 1 -type d | grep -v "^${tmp_dir}$" | head -n 1)
    src_dir="${src_dir}/.opencode"

    if [ -d "$src_dir" ]; then
        find "$src_dir" -type f | while read -r f; do
            local rel="${f#$src_dir/}"
            local checksum=$(get_file_checksum "$f")
            echo "$checksum  $rel"
        done
    fi
    rm -rf "$tmp_dir"
}

compute_installed_checksums() {
    local install_dir="$1"
    find "$install_dir" -type f | while read -r f; do
        local rel="${f#$install_dir/}"
        local checksum=$(get_file_checksum "$f")
        echo "$checksum  $rel"
    done
}

backup_file() {
    local file="$1"
    local backup_dir="${BACKUP_DIR:-$(pwd)/.opencode_backup}"

    mkdir -p "$backup_dir"
    local backup_file="${backup_dir}/${file}"
    mkdir -p "$(dirname "$backup_file")"
    cp "$file" "$backup_file"
    print_info "Backed up: $file -> ${backup_dir}/"
}

perform_update() {
    local patterns
    patterns=$(get_profile_patterns "$PROFILE")

    print_step "Preparing update..."

    local tmpdir=$(mktemp -d)
    local tarfile="${tmpdir}/update.tar.gz"

    local url
    url=$(parse_source_url "$SOURCE_URL")

    print_info "Fetching from: ${url}"
    print_info "Install dir:   ${INSTALL_DIR}"

    if ! curl -fsSL "$url" -o "$tarfile"; then
        print_error "Failed to download from $url"
        rm -rf "$tmpdir"
        exit 1
    fi

    if ! file "$tarfile" | grep -qi gzip; then
        print_error "Downloaded file is not a valid archive"
        rm -rf "$tmpdir"
        exit 1
    fi

    # Extract remote tar to temp dir
    local remote_dir="${tmpdir}/remote"
    tar -xzf "$tarfile" -C "$tmpdir"
    remote_dir=$(find "$tmpdir" -maxdepth 1 -type d | grep -v "^${tmpdir}$" | head -n 1)
    remote_dir="${remote_dir}/.opencode"

    if [ ! -d "$remote_dir" ]; then
        print_error ".opencode directory not found in archive"
        rm -rf "$tmpdir"
        exit 1
    fi

    print_step "Analyzing changes..."

    # Get remote checksums
    local remote_checksum_file="${tmpdir}/remote_checksums.txt"
    compute_checksums_from_tar "$tarfile" > "$remote_checksum_file"

    # Get installed checksums
    local installed_checksum_file="${tmpdir}/installed_checksums.txt"
    compute_installed_checksums "$INSTALL_DIR" > "$installed_checksum_file"

    # Compare and determine actions
    local to_update=0 to_add=0 to_skip=0 modified_local=0

    # Create associative array for installed checksums
    declare -A installed_map
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        local checksum="${line%%  *}"
        local filepath="${line#*  }"
        installed_map["$filepath"]="$checksum"
    done < "$installed_checksum_file"

    # Create associative array for remote checksums
    declare -A remote_map
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        local checksum="${line%%  *}"
        local filepath="${line#*  }"
        remote_map["$filepath"]="$checksum"
    done < "$remote_checksum_file"

    echo ""
    echo -e "${BOLD}Change Summary:${NC}"
    echo "────────────────────────────────────────────"

    # Check files that exist in both
    for filepath in "${!remote_map[@]}"; do
        if [ -v "installed_map[$filepath]" ]; then
            # File exists in both
            local remote_cs="${remote_map[$filepath]}"
            local installed_cs="${installed_map[$filepath]}"

            if [ "$remote_cs" != "$installed_cs" ]; then
                # Check if local was modified (different from original)
                if [ "$DRY_RUN" = true ]; then
                    echo -e "  ${YELLOW}~${NC} Update:    $filepath"
                else
                    echo -e "  ${YELLOW}~${NC} Update:    $filepath"
                fi
                to_update=$((to_update + 1))
            else
                echo -e "  ${GREEN}✓${NC} Unchanged: $filepath"
                to_skip=$((to_skip + 1))
            fi
        else
            # File exists in remote but not locally
            if [ "$DRY_RUN" = true ]; then
                echo -e "  ${BLUE}+${NC} Add:       $filepath"
            else
                echo -e "  ${BLUE}+${NC} Add:       $filepath"
            fi
            to_add=$((to_add + 1))
        fi
    done

    echo ""
    echo -e "  ${YELLOW}→${NC} To update: ${to_update}"
    echo -e "  ${BLUE}+${NC} To add:    ${to_add}"
    echo -e "  ${GREEN}✓${NC} Unchanged: ${to_skip}"
    echo "────────────────────────────────────────────"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        print_info "Dry run — no changes made"
        rm -rf "$tmpdir"
        return 0
    fi

    print_step "Applying updates..."

    local updated=0 added=0 skipped=0

    # Process updates and additions
    while IFS= read -r rel; do
        [ -z "$rel" ] && continue

        # Skip files not matching profile
        if ! file_matches_profile ".opencode/${rel}" "$patterns"; then
            continue
        fi

        local src_file="${remote_dir}/${rel}"
        local dest_file="${INSTALL_DIR}/${rel}"

        if [ -f "$dest_file" ]; then
            # Backup before overwriting
            backup_file "$dest_file"
            if cp "$src_file" "$dest_file"; then
                updated=$((updated + 1))
            fi
        else
            # New file
            mkdir -p "$(dirname "$dest_file")"
            if cp "$src_file" "$dest_file"; then
                added=$((added + 1))
            fi
        fi
    done <<< "$(get_remote_file_list "$remote_dir")"

    echo ""
    print_success "Update complete!"
    echo -e "  Updated: ${YELLOW}${updated}${NC}"
    echo -e "  Added:   ${BLUE}${added}${NC}"
    echo -e "  Skipped: ${GREEN}${skipped}${NC}"

    if [ -n "$BACKUP_DIR" ]; then
        print_info "Backups saved to: ${BACKUP_DIR}"
    fi

    rm -rf "$tmpdir"
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
    echo "  --source URL         Custom source repo (default: Treon-Studio/agents)"
    echo "  --update            Update existing installation from remote"
    echo "  --dry-run           Preview changes without applying"
    echo "  --backup-dir PATH    Backup directory for overwritten files"
    echo "  --help, -h           Show this help"
    echo ""
    echo -e "${BOLD}Examples:${NC}"
    echo "  $0                          # Interactive mode"
    echo "  $0 full                     # Install everything"
    echo "  $0 developer                # Install dev profile"
    echo "  $0 essential --install-dir ~/.config/opencode"
    echo ""
    echo -e "${BOLD}Update (from remote repo):${NC}"
    echo "  $0 --update                 # Update from default repo"
    echo "  $0 --update --dry-run        # Preview changes"
    echo "  $0 --update --source https://github.com/owner/repo  # Custom repo"
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
            --source)
                SOURCE_URL="$2"
                shift 2
                ;;
            --source=*)
                SOURCE_URL="${1#*=}"
                shift
                ;;
            --update)
                UPDATE_MODE=true
                NON_INTERACTIVE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --backup-dir)
                BACKUP_DIR="$2"
                shift 2
                ;;
            --backup-dir=*)
                BACKUP_DIR="${1#*=}"
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

    if [ "$UPDATE_MODE" = true ]; then
        if [ -z "$PROFILE" ]; then
            PROFILE="full"
        fi
        perform_update
        exit 0
    fi

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
