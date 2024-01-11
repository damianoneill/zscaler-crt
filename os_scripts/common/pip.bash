#!/usr/bin/env bash

# This script configures pip to use the Zscaler root certificate.
# It is macos specific and is called from install-certificate.bash.
# It is not meant to be run directly.
# The script is idempotent and can be run multiple times without any side effects.
# It will append the "cert" line to the existing "[global]" section in pip.conf.
# If the "[global]" section doesn't exist, it will create it.
# It uses osx variants of linux commands, so it will not work on linux.

# Set strict mode to catch errors early
set -euo pipefail

# Path to the Zscaler PEM file passed from the calling script
ZSCALER_PEM_FILE="$DEFAULT_PEM_FILE_PATH/$DEFAULT_PEM_FILE"

# Configure pip to use the custom certificate
configure_pip() {
    PIP_CONFIG_DIR="${HOME_DIR}/.config/pip/"
    PIP_CONF_FILE="${PIP_CONFIG_DIR}/pip.conf"

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

# Main function
main() {
    configure_pip
}

main
