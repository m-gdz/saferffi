// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import * as cp from 'child_process';
import * as path from 'path';
import * as vscode from 'vscode';

import { generateCallHierarchyForWorkspace, saveCallGraphToDisk } from './callgraph';
import { findUnnecessaryUnsafeBlocks, saveUnnecessaryUnsafeBlocksToDisk } from './unusedunsafe';

// This method is called when your extension is activated
// Your extension is activated the very first time the command is executed
export function activate(context: vscode.ExtensionContext) {

	// Use the console to output diagnostic information (console.log) and errors (console.error)
	// This line of code will only be executed once when your extension is activated
	console.log('Congratulations, your extension "oxidize" is now active!');

	// The command has been defined in the package.json file
	// Now provide the implementation of the command with registerCommand
	// The commandId parameter must match the command field in package.json
	

	const disposableWrap = vscode.commands.registerCommand('oxidize.refactor.wrap', async () => {
        let callgraph = await generateCallHierarchyForWorkspace();
        let callGraphPath = path.join(context.extensionPath, 'callgraph.json');
        
        if (callgraph) {
            await saveCallGraphToDisk(callgraph, callGraphPath);
            console.log(callGraphPath);
            vscode.window.showInformationMessage("Call hierarchy generated and saved successfully.");
    
            // Pass the generated callGraphPath as an additional argument to runRascalCommand
            await runRascalCommand(context, ['SaferFFI.rsc', '-v', 'wrap'], [callGraphPath]);
        } else {
            vscode.window.showErrorMessage('Failed to generate callgraph.');
        }
    });

    context.subscriptions.push(disposableWrap);

    const disposableConfig = vscode.commands.registerCommand('oxidize.refactor.config', async () => {
        await runRascalCommand(context, ['SaferFFI.rsc', '-v', 'config']);
    });

    context.subscriptions.push(disposableConfig);
    
    const disposableRemoveUnsafe = vscode.commands.registerCommand('oxidize.refactor.removeunsafe', async () => {

        let unnecessaryUnsafeBlocks = findUnnecessaryUnsafeBlocks();
        let unnecessaryUnsafeBlocksPath = path.join(context.extensionPath, 'unnecessaryUnsafeBlocks.json');
        
        if(unnecessaryUnsafeBlocks){
            saveUnnecessaryUnsafeBlocksToDisk(unnecessaryUnsafeBlocks, unnecessaryUnsafeBlocksPath);
            await runRascalCommand(context, ['SaferFFI.rsc', '-v', 'removeunsafe'], [unnecessaryUnsafeBlocksPath]);
        }

        //await runRascalCommand(context, ['SaferFFI.rsc', '-v', 'removeunsafe']);
    });

    context.subscriptions.push(disposableRemoveUnsafe);

}


async function runRascalCommand(context: vscode.ExtensionContext, rascalArgs: string[] = [], additionalArgs: string[] = []) {
    let projectPath = "" + vscode.workspace.workspaceFolders?.[0].uri.fsPath;

    // Combine Rascal args with any additional arguments
    const fullArgs = ['-Xmx1G', '-Xss32m', '-jar', "rascal.jar", ...rascalArgs, ...additionalArgs, projectPath];
    console.log(fullArgs);
    // Spawn the Java process running Rascal
    const rascalProcess = cp.spawn('java', fullArgs, {
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
}


// This method is called when your extension is deactivated
export function deactivate() {}
