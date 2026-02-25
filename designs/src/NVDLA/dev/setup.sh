#!/usr/bin/env bash
# =============================================================================
# Master Setup Script
# Installs: Java JDK 1.7, Perl 5.10 (+ XML::Simple, Capture::Tiny),
#           GCC 4.9.3, Python 2.6, SystemC 2.3.0
# =============================================================================
set -euo pipefail

# --- Configuration -----------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/setup_master.log"
FAILED_INSTALLS=()

# --- Colors ------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

log()     { echo -e "${GREEN}[INFO]${NC}  $*" | tee -a "$LOG_FILE"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*" | tee -a "$LOG_FILE"; }
err()     { echo -e "${RED}[ERROR]${NC} $*" | tee -a "$LOG_FILE"; }
section() { echo -e "\n${BLUE}${BOLD}========== $* ==========${NC}" | tee -a "$LOG_FILE"; }

# --- Pre-flight checks -------------------------------------------------------
[[ $EUID -eq 0 ]] || { echo -e "${RED}[ERROR]${NC} This script must be run as root (use sudo)."; exit 1; }

# --- Usage / Options ---------------------------------------------------------
usage() {
    cat <<EOF
Usage: sudo $0 [OPTIONS]

Options:
  --all              Install all packages (default if no flags given)
  --java             Install Java JDK 1.7
  --perl             Install Perl 5.10 + XML::Simple + Capture::Tiny
  --gcc              Install GCC 4.9.3
  --python           Install Python 2.6
  --systemc          Install SystemC 2.3.0
  --systemc-tarball  Path to the SystemC tarball (required for --systemc)
  -h, --help         Show this help message

Examples:
  sudo $0 --all
  sudo $0 --java --perl
  sudo $0 --systemc --systemc-tarball /path/to/systemc-2.3.0.tar.gz
EOF
}

# --- Parse arguments ---------------------------------------------------------
INSTALL_JAVA=false
INSTALL_PERL=false
INSTALL_GCC=false
INSTALL_PYTHON=false
INSTALL_SYSTEMC=false
SYSTEMC_TARBALL=""

if [[ $# -eq 0 ]]; then
    INSTALL_JAVA=true
    INSTALL_PERL=true
    INSTALL_GCC=true
    INSTALL_PYTHON=true
    INSTALL_SYSTEMC=true
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --all)              INSTALL_JAVA=true; INSTALL_PERL=true; INSTALL_GCC=true;
                            INSTALL_PYTHON=true; INSTALL_SYSTEMC=true ;;
        --java)             INSTALL_JAVA=true ;;
        --perl)             INSTALL_PERL=true ;;
        --gcc)              INSTALL_GCC=true ;;
        --python)           INSTALL_PYTHON=true ;;
        --systemc)          INSTALL_SYSTEMC=true ;;
        --systemc-tarball)  SYSTEMC_TARBALL="$2"; shift ;;
        -h|--help)          usage; exit 0 ;;
        *)                  warn "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
done

# --- Helper: run a sub-script ------------------------------------------------
run_script() {
    local name="$1"
    local script="$2"
    shift 2
    local extra_env=("$@")

    section "Installing: ${name}"

    if [[ ! -f "${SCRIPT_DIR}/${script}" ]]; then
        err "Script not found: ${SCRIPT_DIR}/${script}"
        FAILED_INSTALLS+=("$name (script missing)")
        return
    fi

    chmod +x "${SCRIPT_DIR}/${script}"

    local env_prefix=""
    for e in "${extra_env[@]}"; do
        env_prefix="${env_prefix} ${e}"
    done

    if eval "env ${env_prefix} bash '${SCRIPT_DIR}/${script}'" 2>&1 | tee -a "$LOG_FILE"; then
        log "✓ ${name} installed successfully."
    else
        err "✗ ${name} installation failed. See ${LOG_FILE} for details."
        FAILED_INSTALLS+=("$name")
    fi
}

# --- Print summary header ----------------------------------------------------
print_header() {
    echo -e "${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           Master Installation Script                        ║"
    echo "║  Java JDK 1.7 | Perl 5.10 | GCC 4.9.3 | Python 2.6        ║"
    echo "║  SystemC 2.3.0                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    log "Master setup started at $(date)"
    log "Log file: ${LOG_FILE}"

    # Print what will be installed
    echo -e "\n${BOLD}Packages to install:${NC}"
    $INSTALL_JAVA    && echo "  • Java JDK 1.7"
    $INSTALL_PERL    && echo "  • Perl 5.10 (XML::Simple, Capture::Tiny)"
    $INSTALL_GCC     && echo "  • GCC 4.9.3 (C/C++)"
    $INSTALL_PYTHON  && echo "  • Python 2.6"
    $INSTALL_SYSTEMC && echo "  • SystemC 2.3.0"
    echo ""
}

# --- Print final summary -----------------------------------------------------
print_summary() {
    section "Installation Summary"
    echo ""

    local success_count=0
    local total=0

    $INSTALL_JAVA   && ((total++))
    $INSTALL_PERL   && ((total++))
    $INSTALL_GCC    && ((total++))
    $INSTALL_PYTHON && ((total++))
    $INSTALL_SYSTEMC && ((total++))

    success_count=$(( total - ${#FAILED_INSTALLS[@]} ))

    echo -e "${BOLD}Results: ${success_count}/${total} packages installed successfully${NC}"
    echo ""

    if [[ ${#FAILED_INSTALLS[@]} -gt 0 ]]; then
        echo -e "${RED}Failed installations:${NC}"
        for pkg in "${FAILED_INSTALLS[@]}"; do
            echo "  ✗ ${pkg}"
        done
        echo ""
        echo "Please review the log file for details: ${LOG_FILE}"
    else
        echo -e "${GREEN}All packages installed successfully!${NC}"
    fi

    echo ""
    echo -e "${YELLOW}NOTE: Run 'source /etc/profile' or start a new shell to load${NC}"
    echo -e "${YELLOW}      the updated PATH and environment variables.${NC}"
    echo ""
    log "Master setup finished at $(date)"
}

# --- Main --------------------------------------------------------------------
print_header

# GCC should be installed first (SystemC and Python may depend on it)
$INSTALL_GCC     && run_script "GCC 4.9.3"     "setup_cpp_gcc-4.9.3.sh"
$INSTALL_JAVA    && run_script "Java JDK 1.7"  "setup_java_jdk1.7.sh"
$INSTALL_PERL    && run_script "Perl 5.10"     "setup_perl_5.10.sh"
$INSTALL_PYTHON  && run_script "Python 2.6"    "setup_python_2.6.sh"

if $INSTALL_SYSTEMC; then
    if [[ -n "$SYSTEMC_TARBALL" ]]; then
        run_script "SystemC 2.3.0" "setup_systemc-2.3.0.sh" "TARBALL=${SYSTEMC_TARBALL}"
    else
        run_script "SystemC 2.3.0" "setup_systemc-2.3.0.sh"
    fi
fi

print_summary