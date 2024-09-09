# oxidize README

This is the README for the VS Code extension "saferffi".

## Features

- **Wrap Refactoring**: Automatically wraps functions with `safe_` prefixes and replaces relevant function calls using a callgraph.
- **Remove Unsafe Blocks**: Identifies and removes unnecessary unsafe blocks based on a provided `unsafe.json`.
- **Config Refactoring**: Perform general configuration refactoring.
  

## Requirements

- Rust installed in your environment.
- The `rascal-analyzer` extension and `java` installed on your machine.

## Extension Settings

This extension contributes the following settings:

* `oxidize.verbose`: Enable/disable verbose logging for refactoring processes.
  
## Known Issues

- Issues may arise if the `callgraph.json` or `unsafe.json` files are missing or incorrectly formatted.
- Large Rust projects might experience delays during the wrapping process due to extensive callgraph analysis.

## Release Notes

### 0.0.1

Initial release of Oxidize with support for `wrap`, `removeunsafe`, and `config` refactoring options.

