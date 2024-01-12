#!/usr/bin/env bash

# Set strict mode to catch errors early
set -euo pipefail

SYSTEM_CERTIFICATE_STORE="$(openssl version -d | sed -n 's/OPENSSLDIR: \(.*\)/\1/p' | tr -d '"')"

# Adding the zscaler certificate to the openssl system trust store
configure() {
    # Check if the Zscaler certificate is already present in SYSTEM_CERTIFICATE_STORE
    if ! openssl verify -CAfile <(cat "$SYSTEM_CERTIFICATE_STORE"/cert.pem) "$DEFAULT_PEM_FILE_PATH/$DEFAULT_PEM_FILE" >/dev/null 2>&1; then
        echo "Appending Zscaler certificate to $SYSTEM_CERTIFICATE_STORE/cert.pem"

        # Append the Zscaler certificate to the SYSTEM_CERTIFICATE_STORE
        cat "$DEFAULT_PEM_FILE_PATH/$DEFAULT_PEM_FILE" >>"$SYSTEM_CERTIFICATE_STORE/cert.pem"

        echo "Zscaler certificate successfully added."
    fi
}

# Assert that the configuration is working
assert() {
    if openssl verify -CAfile <(cat "$SYSTEM_CERTIFICATE_STORE"/cert.pem) "$DEFAULT_PEM_FILE_PATH/$DEFAULT_PEM_FILE" >/dev/null 2>&1; then
        echo "Asserting: Zscaler certificate is present in $SYSTEM_CERTIFICATE_STORE."
    else
        echo "Assertion failed: Zscaler certificate is not present in $SYSTEM_CERTIFICATE_STORE."
        exit 1
    fi
}

check() {
    # check if openssl is installed, return error code if not
    if ! command -v openssl >/dev/null 2>&1; then
        echo "openssl is not installed, ignoring"
        return 1
    fi
}

# Main function
main() {
    check || exit 0

    # configure the system trust store with the zscaler certificate
    echo "Configuring: Adding the zscaler certificate to the openssl system trust store [$SYSTEM_CERTIFICATE_STORE]"
    configure
    assert
}

main
