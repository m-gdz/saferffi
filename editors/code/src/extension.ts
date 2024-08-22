// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import * as cp from 'child_process';
import * as path from 'path';
import * as vscode from 'vscode';

import { generateCallHierarchyForWorkspace } from './callgraph';

// This method is called when your extension is activated
// Your extension is activated the very first time the command is executed
export function activate(context: vscode.ExtensionContext) {

	// Use the console to output diagnostic information (console.log) and errors (console.error)
	// This line of code will only be executed once when your extension is activated
	console.log('Congratulations, your extension "oxidize" is now active!');

	// The command has been defined in the package.json file
	// Now provide the implementation of the command with registerCommand
	// The commandId parameter must match the command field in package.json
	const disposable = vscode.commands.registerCommand('oxidize.helloWorld', () => {
		// The code you place here will be executed every time your command is executed
		// Display a message box to the user
		//vscode.window.showInformationMessage('Hello World from oxidize: '+context.extensionPath);
		

        // Spawn the Java process running Rascal
        const rascalProcess = cp.spawn('java', ['-Xmx1G', '-Xss32m', '-jar', "rascal.jar", "SaferFFI.rsc", "nice !"], {
			cwd: path.join(context.extensionPath, '../../src/main/rascal'),
            stdio: ['pipe', 'pipe', 'pipe'] // stdin, stdout, stderr
        });

        // Example complex data structure
        // const complexData = {
        //     name: "MyProject",
        //     files: ["file1.rsc", "file2.rsc"],
        //     config: {
        //         optionA: true,
        //         optionB: "valueB"
        //     }
        // };

        // Serialize the data structure to JSON and send it to Rascal via stdin
        // rascalProcess.stdin.write(JSON.stringify(complexData));
        // rascalProcess.stdin.end();

        // Listen for data from Rascal's stdout
        let result = '';
        rascalProcess.stdout.on('data', (data) => {
            result += data.toString();  // Collect the data
        });

        // Handle completion of the process
        rascalProcess.stdout.on('end', () => {
            vscode.window.showInformationMessage(`Rascal Output: ${result}`);
        });

        // Handle errors
        rascalProcess.stderr.on('data', (data) => {
            vscode.window.showErrorMessage(`Rascal Error: ${data.toString()}`);
        });

        rascalProcess.on('close', (code) => {
            vscode.window.showInformationMessage(`Rascal process exited with code ${code}`);
        });
	});

	context.subscriptions.push(disposable);

	// New command registration
    let newCommandDisposable = vscode.commands.registerCommand('extension.getCallGraph', () => {
        generateCallHierarchyForWorkspace();
    });

    context.subscriptions.push(newCommandDisposable);
}

// This method is called when your extension is deactivated
export function deactivate() {}
