#!/usr/bin/env bash

# Set strict mode to catch errors early
set -euo pipefail

# Path to the Zscaler PEM file passed from the calling script
ZSCALER_PEM_FILE="$DEFAULT_PEM_FILE_PATH/$DEFAULT_PEM_FILE"

PIP_CONFIG_DIR="${HOME_DIR}/.config/pip/"
PIP_CONF_FILE="${PIP_CONFIG_DIR}/pip.conf"

# Configure pip to use custom certificate
configure() {
    # Create pip config directory if it doesn't exist
    mkdir -p "$PIP_CONFIG_DIR"

    # Check if the pip.conf file exists or create it
    if [ ! -f "$PIP_CONF_FILE" ]; then
        touch "$PIP_CONF_FILE"
    fi

    # Check if the "[global]" section exists in the file
    if grep -qFx "[global]" "$PIP_CONF_FILE"; then
        # Check if the "cert" line exists in the "[global]" section
        if ! grep -qFx "cert = $ZSCALER_PEM_FILE" "$PIP_CONF_FILE"; then
            # Append the "cert" line to the "[global]" section
            awk '/\[global\]/{print; print "cert = '"$ZSCALER_PEM_FILE"'"; next} 1' "$PIP_CONF_FILE" >"$PIP_CONF_FILE.tmp"
            mv "$PIP_CONF_FILE.tmp" "$PIP_CONF_FILE"
            echo "Added cert line to the existing [global] section in pip.conf"
        fi
    else
        # Create or update pip configuration file with the "[global]" section
        {
            echo "[global]"
            echo "cert = $ZSCALER_PEM_FILE"
        } >>"$PIP_CONF_FILE"

        echo "Pip configured to use the custom certificate at: $ZSCALER_PEM_FILE"
    fi
}

# Assert that the configuration is working
assert() {
    # assert that configuration of zscaler cert has been applied
    if ! pip config list | grep -qFx "global.cert='$ZSCALER_PEM_FILE'"; then
        echo "Failed to configure pip to use the custom certificate at: $ZSCALER_PEM_FILE"
        exit 1
    fi
    # assert that pip is able to install packages
    if ! pip install -q --upgrade pip; then
        echo "Assertion: Failed to install packages using pip"
        exit 1
    else
        echo "Assertion: Successfully installed packages using pip through zscaler"
    fi
}

check() {
    # check if pip is installed, return error code if not
    if ! command -v pip >/dev/null 2>&1; then
        echo "pip is not installed, ignoring"
        return 1
    fi
    # check pip version is 22.2 or higher
    pip_version=$(pip --version | awk '{print $2}')
    if ! [[ "${pip_version}" =~ ^[2-9][2-9]\. ]]; then
        echo "pip version is not 22.2 or higher, ignoring"
        return 1
    fi
}

# Main function
main() {
    # call check pip function and exit if pip is not installed or version is not 22.2 or higher
    check || exit 0

    # configure pip to use the system trust store
    echo "Configuring: pip [$PIP_CONF_FILE] to use the custom certificate at: $ZSCALER_PEM_FILE"
    configure
    assert
}

main
