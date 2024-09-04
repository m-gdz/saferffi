// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import * as cp from 'child_process';
import * as path from 'path';
import * as vscode from 'vscode';

import { generateCallHierarchyForWorkspace, saveCallGraphToDisk } from './callgraph';

// This method is called when your extension is activated
// Your extension is activated the very first time the command is executed
export function activate(context: vscode.ExtensionContext) {

	// Use the console to output diagnostic information (console.log) and errors (console.error)
	// This line of code will only be executed once when your extension is activated
	console.log('Congratulations, your extension "oxidize" is now active!');

	// The command has been defined in the package.json file
	// Now provide the implementation of the command with registerCommand
	// The commandId parameter must match the command field in package.json
	const disposable = vscode.commands.registerCommand('oxidize.refactor', async () => {
		// The code you place here will be executed every time your command is executed
		// Display a message box to the user
		//vscode.window.showInformationMessage('Hello World from oxidize: '+context.extensionPath);
        let projectPath = ""+ vscode.workspace.workspaceFolders?.[0].uri.fsPath;
        let callgraph = await generateCallHierarchyForWorkspace();
        let callGraphPath = path.join(context.extensionPath, 'callgraph.json')
        if(callgraph){
            await saveCallGraphToDisk(callgraph, callGraphPath);
            console.log(callGraphPath);
            vscode.window.showInformationMessage("Call hierarchy generated and saved successfully.");
        }

        // Spawn the Java process running Rascal
        const rascalProcess = cp.spawn('java', ['-Xmx1G', '-Xss32m', '-jar', "rascal.jar", "SaferFFI.rsc", projectPath, "-c", callGraphPath], {
            cwd: path.join(context.extensionPath, '../../src/main/rascal'),
            stdio: ['pipe', 'pipe', 'pipe'] // stdin, stdout, stderr
        });


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

    const disposable2 = vscode.commands.registerCommand('oxidize.getDiagnostics', async () => {
        const allDiagnostics = vscode.languages.getDiagnostics();
        for (const [uri, diagnostics] of allDiagnostics) {
            console.log(uri.toString());
            for (const diagnostic of diagnostics) {
                if (diagnostic.message.startsWith("unnecessary `unsafe` block")) {
                    const range = diagnostic.range;
                    vscode.window.showInformationMessage(`Unnecessary unsafe block at ${range.start.line}:${range.start.character} - ${range.end.line}:${range.end.character}`);
                }
            }
        }
    });

    context.subscriptions.push(disposable2);

}

// This method is called when your extension is deactivated
export function deactivate() {}
