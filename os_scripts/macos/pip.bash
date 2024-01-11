#!/usr/bin/env bash

# Set strict mode to catch errors early
set -euo pipefail

PIP_CONFIG_DIR="${HOME_DIR}/.config/pip/"
PIP_CONF_FILE="${PIP_CONFIG_DIR}/pip.conf"

# Configure pip to use the system trust store, which should contain the zscaler certificate
configure() {

    # Create pip config directory if it doesn't exist
    mkdir -p "$PIP_CONFIG_DIR"

    # Check if the pip.conf file exists or create it
    if [ ! -f "$PIP_CONF_FILE" ]; then
        touch "$PIP_CONF_FILE"
    fi

    # Check if the "[global]" section exists in the file
    if grep -qFx "[global]" "$PIP_CONF_FILE"; then
        # Check if the "use-feature" line exists in the "[global]" section
        if ! grep -qFx "use-feature = truststore" "$PIP_CONF_FILE"; then
            # Append the "use-feature" line to the "[global]" section
            awk '/\[global\]/{print; print "use-feature = truststore"; next} 1' "$PIP_CONF_FILE" >"$PIP_CONF_FILE.tmp"
            mv "$PIP_CONF_FILE.tmp" "$PIP_CONF_FILE"
            echo "Added use-feature line to the existing [global] section in pip.conf"
        fi
    else
        # Create or update pip configuration file with the "[global]" section
        {
            echo "[global]"
            echo "use-feature = truststore"
        } >>"$PIP_CONF_FILE"

        echo "Pip configured to use the system trust store"
    fi

}

# Assert that the configuration is working
assert() {
    # assert that configuration of zscaler cert has been applied
    if ! pip config list | grep -qFx "global.use-feature='truststore'"; then
        echo "Failed to configure pip to use the system trust store"
        exit 1
    fi
    # assert that pip is able to install packages
    echo "Asserting pip install through zscaler ..."
    if ! pip install -q --upgrade pip; then
        echo "Failed to install packages using pip"
        exit 1
    fi
}

check_pip() {
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
    check_pip || exit 0

    # configure pip to use the system trust store
    echo "Configuring pip [$PIP_CONF_FILE] to use the system trust store"
    configure
    assert

}

main
