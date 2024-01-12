#!/usr/bin/env bash

# Set strict mode to catch errors early
set -euo pipefail

username=$(whoami)
default_shell=$(dscl . -read "/Users/$username" UserShell | awk '{print $2}')

# Path to the Zscaler PEM file passed from the calling script
ZSCALER_PEM_FILE="$DEFAULT_PEM_FILE_PATH/$DEFAULT_PEM_FILE"


configure() {
    # switch on shell type
    case "$default_shell" in
    "/bin/bash")
        # check if the zscaler cert is already present in the bash profile
        if ! grep -qFx "export REQUESTS_CA_BUNDLE=$ZSCALER_PEM_FILE" "$HOME_DIR/.bash_profile"; then
            # append the zscaler cert to the bash profile
            echo "export REQUESTS_CA_BUNDLE=$ZSCALER_PEM_FILE" >>"$HOME_DIR/.bash_profile"
            echo "Zscaler certificate successfully added to $HOME_DIR/.bash_profile"
        fi
        ;;
    "/bin/zsh")
        # check if the zscaler cert is already present in the zsh profile
        if ! grep -qFx "export REQUESTS_CA_BUNDLE=$ZSCALER_PEM_FILE" "$HOME_DIR/.zshrc"; then
            # append the zscaler cert to the zsh profile
            echo "export REQUESTS_CA_BUNDLE=$ZSCALER_PEM_FILE" >>"$HOME_DIR/.zshrc"
            echo "Zscaler certificate successfully added to $HOME_DIR/.zshrc"
        fi
        ;;
    *)
        echo "Unsupported shell type: $default_shell"
        exit 1
        ;;
    esac
}

assert() {
    return
}

check() {
    return
}

# Main function
main() {
    check || exit 0

    # configure requests to use the custom certificate
    echo "Configuring: requests to use the custom certificate at: $ZSCALER_PEM_FILE"
    configure
    assert
}

main