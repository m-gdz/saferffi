import * as vscode from 'vscode';

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

    // 5. Process the call graph data
    console.log(callGraph);
    vscode.window.showInformationMessage("Call hierarchy generated successfully.");
}

// Example usage of the function within a command
vscode.commands.registerCommand('extension.generateCallHierarchy', generateCallHierarchyForWorkspace);

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

            const itemLocationString = locationToString(item.uri, item.range);

            if (!callGraph.has(itemLocationString)) {
                callGraph.set(itemLocationString, new Set<string>());
            }

            const incomingCalls = await vscode.commands.executeCommand<vscode.CallHierarchyIncomingCall[]>('vscode.provideIncomingCalls', item);
            if (incomingCalls && incomingCalls.length > 0) {
                for (const call of incomingCalls) {
                    const callerLocationString = locationToString(call.from.uri, call.from.range);
                    callGraph.get(itemLocationString)?.add(callerLocationString);
                }
            }
        }
    }

    return callGraph;
}

function locationToString(uri: vscode.Uri, range: vscode.Range): string {
    return `${uri.toString()} (Offset: ${range.start.character}, Length: ${range.end.character - range.start.character}, Start: <${range.start.line}, ${range.start.character}>, End: <${range.end.line}, ${range.end.character}>)`;
}

const FUNC_KINDS: readonly vscode.SymbolKind[] = [vscode.SymbolKind.Function, vscode.SymbolKind.Method, vscode.SymbolKind.Constructor];

function normalizedPath(path: string): string {
    return process.platform === 'win32' ? path.replace(/^\/\w+(?=:)/, drive => drive.toUpperCase()) : path;
}
