#!/usr/bin/env bash

# Set strict mode to catch errors early
set -euo pipefail

# Path to the Zscaler PEM file passed from the calling script
ZSCALER_PEM_FILE="$DEFAULT_PEM_FILE_PATH/$DEFAULT_PEM_FILE"

PIP_CONFIG_DIR="${HOME_DIR}/.config/pip/"
PIP_CONF_FILE="${PIP_CONFIG_DIR}/pip.conf"

# Configure pip to use the custom certificate
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
    echo "Asserting pip install through zscaler ..."
    if ! pip install -q --upgrade pip; then
        echo "Failed to install packages using pip"
        exit 1
    fi
}

# Main function
main() {
    # configure if pip is installed
    if command -v pip >/dev/null 2>&1; then
        echo "Configuring pip [$PIP_CONF_FILE] to use the custom certificate at: $ZSCALER_PEM_FILE"
        configure
        assert
    else
        echo "pip is not installed, ignoring"
    fi
}

main
