#!/bin/bash

#===============================================================================
# MSYS2 Package Installer
#
# Usage:
#   ./setup-msys2.sh 
#   ./setup-msys2.sh --dry-run
#   ./setup-msys2.sh --help
#===============================================================================

#-------------------------------------------------------------------------------
# CONFIGURATION
#-------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/msys2-setup.log"
DRY_RUN=false

# Counters
TOTAL_COUNT=0
SUCCESS_COUNT=0
FAIL_COUNT=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

#-------------------------------------------------------------------------------
# PACKAGE DEFINITIONS
#-------------------------------------------------------------------------------

MSYS_PACKAGES=(
    base-devel
    git
    zsh
    vim
    nano
    tree
    zip
    unzip
    curl
    wget
    openssh
)

MINGW_PACKAGES=(
    mingw-w64-ucrt-x86_64-neovim
    mingw-w64-ucrt-x86_64-fd
    mingw-w64-ucrt-x86_64-ripgrep
    mingw-w64-ucrt-x86_64-fzf
    mingw-w64-ucrt-x86_64-fastfetch
    mingw-w64-ucrt-x86_64-nodejs
)

#-------------------------------------------------------------------------------
# HELPER FUNCTIONS
#-------------------------------------------------------------------------------

log() {
    local message="$1"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] ${message}" >> "${LOG_FILE}"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "  ${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "  ${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════╗"
    echo "║       MSYS2 Package Installer        ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
}

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -n, --dry-run    Xem trước packages sẽ cài (không cài thật)"
    echo "  -h, --help       Hiển thị hướng dẫn này"
    echo ""
    echo "Examples:"
    echo "  $0               # Cài đặt tất cả packages"
    echo "  $0 --dry-run     # Chỉ xem, không cài"
    echo ""
    echo "Log file: ${LOG_FILE}"
    exit 0
}

# Args: $1 = environment name (MSYS/MINGW64), $2... = packages
install_packages() {
    local env_name="$1"
    shift
    local packages=("$@")

    echo ""
    echo -e "${CYAN}[${env_name}]${NC} Installing packages..."
    log "[${env_name}] Starting installation..."

    for package in "${packages[@]}"; do
        ((TOTAL_COUNT++))

        if [[ "${DRY_RUN}" == true ]]; then
            print_success "${package} ${YELLOW}(dry-run)${NC}"
            log "[${env_name}] ${package}: DRY-RUN"
            ((SUCCESS_COUNT++))
        else
            if pacman -S --noconfirm --needed "${package}" >> "${LOG_FILE}" 2>&1; then
                print_success "${package}"
                log "[${env_name}] ${package}: SUCCESS"
                ((SUCCESS_COUNT++))
            else
                print_error "${package} (check log for details)"
                log "[${env_name}] ${package}: FAILED"
                ((FAIL_COUNT++))
            fi
        fi
    done

    log "[${env_name}] Completed."
}

#-------------------------------------------------------------------------------
# ARGUMENT PARSING
#-------------------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information."
            exit 1
            ;;
    esac
done

#-------------------------------------------------------------------------------
# MAIN EXECUTION
#-------------------------------------------------------------------------------

print_banner

{
    echo "========================================"
    echo "MSYS2 Setup Log"
    echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "========================================"
    echo ""
} > "${LOG_FILE}"

print_info "Log file: ${LOG_FILE}"

if [[ "${DRY_RUN}" == true ]]; then
    print_warning "DRY RUN MODE - No packages will be installed"
    log "MODE: DRY-RUN"
else
    log "MODE: INSTALL"
fi

print_info "Updating package database..."
if [[ "${DRY_RUN}" == false ]]; then
    if pacman -Sy >> "${LOG_FILE}" 2>&1; then
        log "Package database updated successfully"
    else
        print_error "Failed to update package database"
        log "Package database update: FAILED"
    fi
else
    log "Package database update: SKIPPED (dry-run)"
fi

install_packages "MSYS" "${MSYS_PACKAGES[@]}"

install_packages "MINGW64" "${MINGW_PACKAGES[@]}"

echo ""
echo "════════════════════════════════════════"
if [[ "${FAIL_COUNT}" -eq 0 ]]; then
    echo -e "${GREEN}Summary: ${TOTAL_COUNT} total | ${SUCCESS_COUNT} success | ${FAIL_COUNT} failed${NC}"
else
    echo -e "${YELLOW}Summary: ${TOTAL_COUNT} total | ${SUCCESS_COUNT} success | ${RED}${FAIL_COUNT} failed${NC}"
fi
echo "Log saved to: ${LOG_FILE}"
echo "════════════════════════════════════════"

{
    echo ""
    echo "========================================"
    echo "Summary"
    echo "Total: ${TOTAL_COUNT} | Success: ${SUCCESS_COUNT} | Failed: ${FAIL_COUNT}"
    echo "Finished: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "========================================"
} >> "${LOG_FILE}"

if [[ "${FAIL_COUNT}" -gt 0 ]]; then
    exit 1
fi

exit 0
