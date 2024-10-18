// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import * as cp from 'child_process';
import * as path from 'path';
import * as vscode from 'vscode';

import { generateCallHierarchyForWorkspace, saveCallGraphToDisk } from './callgraph';
import { findUnnecessaryUnsafeBlocks, saveUnnecessaryUnsafeBlocksToDisk } from './unusedunsafe';
import { generateReferenceMapForWorkspace, saveReferenceMapToDisk } from './references';

// This method is called when your extension is activated
// Your extension is activated the very first time the command is executed
export function activate(context: vscode.ExtensionContext) {

    // Use the console to output diagnostic information (console.log) and errors (console.error)
    // This line of code will only be executed once when your extension is activated
    console.log('Congratulations, your extension "saferffi" is now active!');

    // The command has been defined in the package.json file
    // Now provide the implementation of the command with registerCommand
    // The commandId parameter must match the command field in package.json

    const disposable = vscode.commands.registerCommand('saferffi.launchRascal', () => {

    
        var rascalExtension =  vscode.extensions.getExtension( 'usethesource.rascalmpl' );

        // is the ext loaded and ready?
        if( rascalExtension && rascalExtension.isActive == false ){
            rascalExtension.activate().then(
                function(){
                    console.log( "Extension activated");
                    vscode.workspace.openTextDocument(vscode.Uri.file('/Users/potato/Developer/Projects/saferffi/editors/code/resources/main/rascal/Oxidize.rsc')).then((document) => {
                        vscode.window.showTextDocument(document, { preview: false }).then(() => {
                            vscode.commands.executeCommand("rascalmpl.importModule", "SaferFFI");
                        });
                    });

                    //vscode.commands.executeCommand("rascalmpl.importModule", "'"+path.join(context.extensionPath, 'resources/src/main/rascal/Oxidize.rsc')+"'");
                },
                function(){
                    console.log( "Extension activation failed");
                }
            );   
        } else {
            //vscode.commands.executeCommand("xmlTools.formatAsXml");
        }


        // vscode.commands.executeCommand("usethesource.rascalmpl.startTerminal", path.join(context.extensionPath, 'resources/src/main/rascal'), "--loadModule", "Oxidize.rsc")
        // .then(
        //     () => {
        //         vscode.window.showInformationMessage(`Module imported successfully.`);
        //     },
        //     (err) => {
        //         vscode.window.showErrorMessage(`Failed to import module: ${err}`);
        //     }
        // );
    });

    context.subscriptions.push(disposable);


    const disposableWrap = vscode.commands.registerCommand('saferffi.refactor.wrap', async () => {
        let referenceMap = await generateReferenceMapForWorkspace();

        let referenceMapPath = path.join(context.extensionPath, 'references.json');


        if (referenceMap) {

            await saveReferenceMapToDisk(referenceMap, referenceMapPath);
            vscode.window.showInformationMessage("Reference map generated and saved successfully.");
            await runRascalCommand(context, ['Oxidize.rsc', '-v', 'wrap'], [referenceMapPath]);

        } else {
            vscode.window.showErrorMessage("Failed to save reference map.");
        }

        // let callgraph = await generateCallHierarchyForWorkspace();


        // let callGraphPath = path.join(context.extensionPath, 'callgraph.json');

        // if (callgraph) {
        //     await saveCallGraphToDisk(callgraph, callGraphPath);
        //     console.log(callGraphPath);
        //     vscode.window.showInformationMessage("Call hierarchy generated and saved successfully.");

        //     // Pass the generated callGraphPath as an additional argument to runRascalCommand
        //     await runRascalCommand(context, ['Oxidize.rsc', '-v', 'wrap'], [callGraphPath]);
        // } else {
        //     vscode.window.showErrorMessage('Failed to generate callgraph.');
        // }
    });

    context.subscriptions.push(disposableWrap);

    const disposableConfig = vscode.commands.registerCommand('saferffi.refactor.config', async () => {
        await runRascalCommand(context, ['Oxidize.rsc', '-v', 'config']);
    });

    context.subscriptions.push(disposableConfig);

    const disposableRemoveUnsafe = vscode.commands.registerCommand('saferffi.refactor.removeunsafe', async () => {

        let unnecessaryUnsafeBlocks = findUnnecessaryUnsafeBlocks();
        let unnecessaryUnsafeBlocksPath = path.join(context.extensionPath, 'unnecessaryUnsafeBlocks.json');

        if (unnecessaryUnsafeBlocks) {
            saveUnnecessaryUnsafeBlocksToDisk(unnecessaryUnsafeBlocks, unnecessaryUnsafeBlocksPath);
            await runRascalCommand(context, ['Oxidize.rsc', '-v', 'removeunsafe'], [unnecessaryUnsafeBlocksPath]);
        }

        //await runRascalCommand(context, ['Oxidize.rsc', '-v', 'removeunsafe']);
    });

    context.subscriptions.push(disposableRemoveUnsafe);

}


async function runRascalCommand(context: vscode.ExtensionContext, rascalArgs: string[] = [], additionalArgs: string[] = []) {
    vscode.window.withProgress({
        location: vscode.ProgressLocation.Notification,
        title: "SaferFFI",
        cancellable: true
    }, (progress, token) => {
        return new Promise<void>((resolve, reject) => {
            let projectPath = "" + vscode.workspace.workspaceFolders?.[0].uri.fsPath;

            // Combine Rascal args with any additional arguments
            const fullArgs = ['-Xmx1G', '-Xss32m', '-jar', "rascal.jar", ...rascalArgs, ...additionalArgs, projectPath];
            console.log(fullArgs);

            // Spawn the Java process running Rascal
            const rascalProcess = cp.spawn('java', fullArgs, {
                cwd: path.join(context.extensionPath, 'resources/main/rascal'),
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
                resolve();  // Process has finished
                vscode.window.showInformationMessage(`Rascal process exited with code ${code}`);
            });

            // Handle cancellation: terminate the process if the user cancels
            token.onCancellationRequested(() => {
                console.log("User canceled the long running operation");
                rascalProcess.kill();  // Terminate the spawned process
                reject(new Error('Process was canceled by the user.'));
                vscode.window.showWarningMessage('Operation was canceled.');
            });
        });
    });
}



// This method is called when your extension is deactivated
export function deactivate() { }
