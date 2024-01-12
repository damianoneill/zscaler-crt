#!/usr/bin/env bash

# This script installs the Zscaler root certificate on the local machine.
# It detects the operating system and runs the appropriate script.
# It runs the common scripts, regardless of what OS is installed on the local machine.

# Set strict mode to catch errors early
set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export SCRIPT_DIR
export DEFAULT_OS_SCRIPTS_DIR="${DEFAULT_OS_SCRIPTS_DIR:-$SCRIPT_DIR/os_scripts}"
export DEFAULT_PEM_FILE="ZscalerRootCA.pem"

# check bash version is 4 or higher
if [ "${BASH_VERSINFO:-0}" -lt 4 ]; then
    echo "Error: Bash version 4 or higher is required, you have ${BASH_VERSION}"
    if [ "$(uname)" == "Darwin" ]; then
        echo "You can install bash 4+ with brew install bash"
    fi
    exit 1
fi

# Define the list of required binaries
REQUIRED_BINARIES=("grep" "awk")

# Function to check if a binary is available
function check_binary() {
    local binary="$1"
    if ! command -v "$binary" &>/dev/null; then
        echo "Error: $binary is not installed or not in your PATH"
        exit 1
    fi
}

# Check if all required binaries are available
for binary in "${REQUIRED_BINARIES[@]}"; do
    check_binary "$binary"
done

# Set default HOME_DIR based on the operating system
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "linux-gnu" ]]; then
    # Windows using MSYS or Cygwin or WSL
    export HOME_DIR="${HOME_DIR:-$USERPROFILE}"
else
    # Unix-like systems
    export HOME_DIR="${HOME_DIR:-$HOME}"
fi

# Set the default PEM file path
export DEFAULT_PEM_FILE_PATH=$HOME_DIR

# Function to install certificates
install_certificates() {
    local os_scripts_folder="$1"
    local scripts=("$os_scripts_folder"/*.bash)
    if [ ${#scripts[@]} -eq 0 ]; then
        echo "No scripts found in $os_scripts_folder. Skipping..."
    else
        for script in "${scripts[@]}"; do
            if [ -f "$script" ]; then
                echo "Running: $script installation script..."
                bash "$script"
            fi
        done
    fi
}

# Function to detect the operating system and install certificates accordingly
detect_os_and_install() {
    check_pem_file
    case "$(uname -s)" in
        Linux*) install_certificates "$DEFAULT_OS_SCRIPTS_DIR/linux" ;;
        Darwin*) install_certificates "$DEFAULT_OS_SCRIPTS_DIR/macos" ;;
        CYGWIN* | MINGW32* | MSYS*) install_certificates "$DEFAULT_OS_SCRIPTS_DIR/windows" ;;
        # log the error and exit
        *) echo "Unsupported operating system. Exiting..." && exit 1 ;;
    esac
    install_certificates "$DEFAULT_OS_SCRIPTS_DIR/common"
}

# Function to check the presence of the PEM file
check_pem_file() {
    if [ ! -f "$DEFAULT_PEM_FILE_PATH/$DEFAULT_PEM_FILE" ]; then
        echo "PEM file $DEFAULT_PEM_FILE_PATH/$DEFAULT_PEM_FILE not found. Exiting..."
        exit 1
    fi
}

# Main function
main() {
    detect_os_and_install
}

main
