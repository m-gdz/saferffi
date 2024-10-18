# SaferFFI

This is the README for the SaferFFI Visual Studio Code extension.

## Features

- **Wrap Refactoring**: Automatically wraps functions with `_wrapped` suffixes and updates function calls using the project's callgraph.
- **Remove Unsafe Blocks**: Detects and removes unnecessary `unsafe` blocks based on the provided `unsafe.json` file.
- **Config Refactoring**: Performs general configuration-based refactoring for Rust projects.

## Requirements

To use the SaferFFI extension, you will need:

- **Rust** installed in your environment.
- **Java** (JDK >= 14) and **Java Runtime Environment (JRE) >= 14**.
- The **Rust-Analyzer** extension (version >= 0.3.2112)
- The **CodeLLDB** extension (version >= 1.10.0)

## Installation

To install the SaferFFI extension:

1. Download the `.vsix` package from the release section of the repository.
2. Open Visual Studio Code and navigate to the Extensions view.
3. Click on the three dots in the top-right corner and select "Install from VSIX…".
4. Select the downloaded `.vsix` package to complete the installation.

## Release Notes

### 0.0.1

- Initial release of SaferFFI with support for `wrap`, `removeunsafe`, and `config` refactoring options.
