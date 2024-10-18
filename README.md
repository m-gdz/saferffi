# SaferFFI 

SaferFFI is a Visual Studio Code extension written in **Typescript** and **Rascal**. This guide will walk you through the pre-requisites, installation, and usage of the tool, as well as provide some insights into development and testing.

The **Rascal** code for the project is located in the root directory under `src/main/rascal`, while the code for the Visual Studio Code extension can be found in the `editors/code` folder. 

## Pre-requisites

To use SaferFFI in Visual Studio Code, you will need the following software installed:

- **Visual Studio Code** (version >= 1.79.0)
  - Extensions required:
    - **Rust-Analyzer** (version >= 0.3.2112)
    - **CodeLLDB** (version >= 1.10.0)
- A working Java environment:
  - **Java Development Kit (JDK)** (version >= 14)
  - **Java Runtime Environment (JRE)** (version >= 14)

## Installation

To install SaferFFI, follow these steps:

1. Download the `.vsix` package from the release section of the repository.
2. Open Visual Studio Code.
3. Click on the Extensions icon in the Activity Bar.
4. Click the three dots in the top-right corner of the Extensions view and select "Install from VSIX…".
   
Once installed, SaferFFI will be ready for use.

## Usage

After installation, you can use SaferFFI to refactor Rust code. Here’s how:

1. Open a Rust project in Visual Studio Code.
2. Press `Ctrl + Shift + P` to open the command palette.
3. Choose a refactoring strategy from the following options:
   - `SaferFFI: Wrap Refactor`
   - `SaferFFI: Remove Unsafe Refactor`
   - `SaferFFI: Config Refactor`
4. The extension will apply the selected refactor to your project.

A new directory will be created, with the suffix `_idiom`, containing the refactored code.

## Development and Testing

### Pre-requisites

For developing and testing new functionalities in SaferFFI, you will need:

- **node.js** (version >= 10.8.2)
- **npm** (version >= 22.8.0)
- **Rascal** (version >= 0.34.0)

We recommend using the **Rascal Metaprogramming Language** extension for VSCode. The Rascal setup guide can be found on the official Rascal website.

### Setup

To set up your development environment:

1. Download the `rascal.jar` file from the Rascal website (version 0.34.0).
2. Clone the SaferFFI repository.
3. Place the `rascal.jar` file in `saferffi/src/main/rascal/rascal.jar`, next to the `Oxidize.rsc` module.

### Extension Development and Testing

To develop and test the extension:

1. Open the `editors/code` folder in Visual Studio Code.
2. Open the terminal.
3. Run `npm install` to install dependencies.
4. Run `npm run copy-rascal` to copy Rascal files to the `editors/code/resources` folder.
5. Press `F5` to launch the extension in debug mode.

You can now test the extension in the new VSCode window with all available commands.

### Rascal Development and Testing

To develop new refactoring functionalities:

1. Open the repository in Visual Studio Code.
2. Open the `Oxidize.rsc` module from the `src/main/rascal` folder.
3. Click on "Import in new Rascal Terminal" to open the Rascal environment with the imported module.
4. Run the refactor by executing the following command:  
   `Oxidize(|<project_path>|, [options])`
   
   Replace `<project_path>` with the location of the project you want to refactor. Here are some available options:
   
   - `verbose=true`: Prints additional info during refactoring.
   - `command="<command>"`: The refactoring command (`wrap`, `remove_unsafe`, `config`).
   - `references=|<location>|`: Path to a JSON file containing project references.
   - `callgraph=|<location>|`: Path to a JSON file containing the project’s call graph.
   - `unsafe_json=|<location>|`: Path to a JSON file listing unnecessary unsafe blocks.

5. Press Enter to run the function.

### Running Rascal from CLI

You can also run **Oxidize** directly from the CLI with the following command:

```bash
java -Xmx1G -Xss32m -jar <rascal-version>.jar Oxidize.rsc [-v] <command> [<command-specific parameters>] <project_path>
```

- `Xmx` and `Xss` values depend on your use case.
- Replace `<rascal-version>` with the correct `rascal.jar` version.
- Replace `<project_path>` with the location of the project.
- Replace `<command>` with the specific command (`wrap`, `removeunsafe`, `config`).
- Add `-v` for verbose output.

This method can be useful for debugging the Rascal module integration.
