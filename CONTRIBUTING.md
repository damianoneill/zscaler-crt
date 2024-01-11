# Contributing to Zscaler CRT

Thank you for considering contributing to the Zscaler CRT project! By contributing, you help make this project better for everyone. Please take a moment to review this document for guidance on how to contribute.

## Approach to additions

Each new script (new feature or new os support for existing feature), should be:

- idempotent, multiple runs result in the same output.
- globally useable, for e.g. for application like virtual environments, the solution should be globally applicable so that it doesn't need to be applied for each new virtual environment that gets created.  For example, the [pip.bash](./os_scripts/macos/pip.bash) use a global config option for the certificate that will be applied to all pip installations.
- if an option exists to use the system trust store, adopt this option, before using the pem directly.

## How to Contribute

1. Fork the repository on GitHub.
2. Clone your forked repository to your local machine:

    ```bash
    git clone https://github.com/your-username/zscaler-crt.git
    cd zscaler-crt
    ```

3. Create a new branch for your changes:

    ```bash
    git checkout -b feature-branch-name
    ```

4. Make your modifications and test them thoroughly.

5. Commit your changes:

    ```bash
    git commit -m "Your descriptive commit message"
    ```

6. Push your changes to your forked repository:

    ```bash
    git push origin feature-branch-name
    ```

7. Open a Pull Request (PR) on GitHub from your forked repository to the main repository.

8. Provide a clear and descriptive title and description for your PR.

## Style Guidelines

Please adhere to the coding style and conventions used in the existing codebase. Ensure your code is well-commented and includes appropriate documentation.

## Reporting Issues

If you encounter any issues or have suggestions, please [open an issue](https://github.com/damianoneill/zscaler-crt/issues) on GitHub. Include as much detail as possible, such as operating system, relevant code snippets, and error messages.

Thank you for contributing to Zscaler CRT!
