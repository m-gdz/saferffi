import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';

export async function generateCallHierarchyForWorkspace() {
    // 1. Create a CancellationTokenSource
    const tokenSource = new vscode.CancellationTokenSource();
    const token = tokenSource.token;

    // 2. Find all Rust files (*.rs) in the opened directory
    const rustFiles = await vscode.workspace.findFiles('**/*.rs', '**/target/**');

    if (rustFiles.length === 0) {
        vscode.window.showInformationMessage("No Rust files found in the workspace.");
        return;
    }

    // 3. Use the getRustCallHierarchy function to retrieve the call hierarchy
    const callHierarchyMap = await getRustCallHierarchy(rustFiles, token);

    // 4. Generate a detailed call graph
    const callGraph = await generateDetailedCallGraph(callHierarchyMap, token);

    // 5. Save the call graph to a JSON file
    // const extensionPath = vscode.extensions.getExtension('your.extension.id')?.extensionPath;
    // if (!extensionPath) {
    //     vscode.window.showErrorMessage("Failed to get extension path.");
    //     return;
    // }

    // const success = await saveCallGraphToDisk(callGraph, path.join(extensionPath, 'callgraph.json'));

    // if (success) {
    //     vscode.window.showInformationMessage("Call hierarchy generated and saved successfully.");
    // } else {
    //     vscode.window.showErrorMessage("Failed to save call hierarchy.");
    // }

    return callGraph;
}

async function getRustCallHierarchy(
    files: vscode.Uri[],
    token: vscode.CancellationToken
): Promise<Map<string, vscode.CallHierarchyItem[]>> {
    const callHierarchyMap = new Map<string, vscode.CallHierarchyItem[]>();

    for (const file of files) {
        if (token.isCancellationRequested) {
            return callHierarchyMap;
        }

        const symbols = await vscode.commands.executeCommand<vscode.DocumentSymbol[]>('vscode.executeDocumentSymbolProvider', file);
        if (!symbols) {
            vscode.window.showErrorMessage(`Document symbol information not available for '${file.fsPath}'`);
            continue;
        }

        const filePath = normalizedPath(file.path);
        callHierarchyMap.set(filePath, []);

        for (const symbol of symbols) {
            const symbolStart = symbol.selectionRange.start;

            if (FUNC_KINDS.includes(symbol.kind)) {
                try {
                    const callHierarchyItems = await vscode.commands.executeCommand<vscode.CallHierarchyItem[]>('vscode.prepareCallHierarchy', file, symbolStart);
                    if (callHierarchyItems && callHierarchyItems.length > 0) {
                        callHierarchyMap.get(filePath)?.push(...callHierarchyItems);
                    }
                } catch (e) {
                    vscode.window.showErrorMessage(`Error retrieving call hierarchy: ${e}`);
                }
            }
        }
    }

    return callHierarchyMap;
}

async function generateDetailedCallGraph(
    callHierarchyMap: Map<string, vscode.CallHierarchyItem[]>,
    token: vscode.CancellationToken
): Promise<Map<string, Set<string>>> {
    const callGraph = new Map<string, Set<string>>();

    for (const [filePath, hierarchyItems] of callHierarchyMap.entries()) {
        for (const item of hierarchyItems) {
            if (token.isCancellationRequested) {
                return callGraph;
            }
            const document = await vscode.workspace.openTextDocument(item.uri);

            const itemLocationString = locationToString(item.uri, item.range, document);

            if (!callGraph.has(itemLocationString)) {
                callGraph.set(itemLocationString, new Set<string>());
            }

            const incomingCalls = await vscode.commands.executeCommand<vscode.CallHierarchyIncomingCall[]>('vscode.provideIncomingCalls', item);
            if (incomingCalls && incomingCalls.length > 0) {
                for (const call of incomingCalls) {
                    const document2 = await vscode.workspace.openTextDocument(call.from.uri);
                    const callerLocationString = locationToString(call.from.uri, call.from.range, document2);
                    callGraph.get(itemLocationString)?.add(callerLocationString);
                }
            }
        }
    }

    return callGraph;
}

// New function to save the call graph as a JSON file
export async function saveCallGraphToDisk(callGraph: Map<string, Set<string>>, filePath: string): Promise<boolean> {
    try {
        // Convert the Map to a JSON-serializable object
        const graphObject: { [key: string]: string[] } = {};
        for (const [key, value] of callGraph) {
            graphObject[key] = Array.from(value);
        }

        // Write the file to disk
        await fs.promises.writeFile(filePath, JSON.stringify(graphObject, null, 2), 'utf8');
        return true;
    } catch (error: any) {
        vscode.window.showErrorMessage(`Error saving call graph: ${error.message}`);
        return false;
    }
}

function locationToString(uri: vscode.Uri, range: vscode.Range, document: vscode.TextDocument): string {
    const offset = document.offsetAt(range.start);
    const length = document.offsetAt(range.end) - offset;
    const beginLine = range.start.line;
    const beginColumn = range.start.character;
    const endLine = range.end.line;
    const endColumn = range.end.character;

    return `|${uri.toString()}|(${offset},${length},<${beginLine},${beginColumn}>,<${endLine},${endColumn}>)`;
}

const FUNC_KINDS: readonly vscode.SymbolKind[] = [vscode.SymbolKind.Function, vscode.SymbolKind.Method, vscode.SymbolKind.Constructor];

function normalizedPath(path: string): string {
    return process.platform === 'win32' ? path.replace(/^\/\w+(?=:)/, drive => drive.toUpperCase()) : path;
}