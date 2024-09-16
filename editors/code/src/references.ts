import * as vscode from 'vscode';
import * as fs from 'fs';
import { normalizedPath, locationToString } from './utils';

export async function generateReferenceMapForWorkspace() {
    // 1. Create a CancellationTokenSource
    const tokenSource = new vscode.CancellationTokenSource();
    const token = tokenSource.token;

    // 2. Find all Rust files (*.rs) in the opened directory
    const rustFiles = await vscode.workspace.findFiles('**/*.rs', '**/target/**');

    if (rustFiles.length === 0) {
        vscode.window.showInformationMessage("No Rust files found in the workspace.");
        return;
    }

    // 3. Use the getRustReferenceMap function to retrieve the references map
    const referenceMap = await getRustReferenceMap(rustFiles, token);

    return referenceMap;
}

async function getRustReferenceMap(
    files: vscode.Uri[],
    token: vscode.CancellationToken
): Promise<Map<string, Set<string>>> {
    const referenceMap = new Map<string, Set<string>>();

    for (const file of files) {
        if (token.isCancellationRequested) {
            return referenceMap;
        }

        const symbols = await vscode.commands.executeCommand<vscode.DocumentSymbol[]>('vscode.executeDocumentSymbolProvider', file);
        if (!symbols) {
            vscode.window.showErrorMessage(`Document symbol information not available for '${file.fsPath}'`);
            continue;
        }

        // Recursively process all symbols
        await processSymbols(symbols, file, referenceMap, token);
    }

    return referenceMap;
}

async function processSymbols(
    symbols: vscode.DocumentSymbol[],
    file: vscode.Uri,
    referenceMap: Map<string, Set<string>>,
    token: vscode.CancellationToken
) {
    for (const symbol of symbols) {
        if (token.isCancellationRequested) {
            return;
        }

        const symbolStart = symbol.selectionRange.start;

        if (FUNC_KINDS.includes(symbol.kind)) {
            try {
                // Use VSCode's reference provider to find references to the function
                const references = await vscode.commands.executeCommand<vscode.Location[]>('vscode.executeReferenceProvider', file, symbolStart);
                if (references && references.length > 0) {
                    const symbolDocument = await vscode.workspace.openTextDocument(file);
                    const symbolLocationString = locationToString(file, symbol.range, symbolDocument);
                    if (!referenceMap.has(symbolLocationString)) {
                        referenceMap.set(symbolLocationString, new Set<string>());
                    }

                    for (const reference of references) {
                        // Check if the reference is the function name in its own declaration
                        if (symbol.selectionRange.contains(reference.range)) {
                            // Skip adding the reference if it's the function name in its own declaration
                            continue;
                        }

                        const document = await vscode.workspace.openTextDocument(reference.uri);
                        const referenceLocationString = locationToString(reference.uri, reference.range, document);
                        referenceMap.get(symbolLocationString)?.add(referenceLocationString);
                    }
                }
            } catch (e) {
                vscode.window.showErrorMessage(`Error retrieving references: ${e}`);
            }
        }

        // Recursively process child symbols (e.g., functions inside modules)
        if (symbol.children && symbol.children.length > 0) {
            await processSymbols(symbol.children, file, referenceMap, token);
        }
    }
}

// Function to save the reference map as a JSON file
export async function saveReferenceMapToDisk(referenceMap: Map<string, Set<string>>, filePath: string): Promise<boolean> {
    try {
        // Convert the Map to a JSON-serializable object
        const mapObject: { [key: string]: string[] } = {};
        for (const [key, value] of referenceMap) {
            mapObject[key] = Array.from(value);
        }

        // Write the file to disk
        await fs.promises.writeFile(filePath, JSON.stringify(mapObject, null, 2), 'utf8');
        return true;
    } catch (error: any) {
        vscode.window.showErrorMessage(`Error saving reference map: ${error.message}`);
        return false;
    }
}

const FUNC_KINDS: readonly vscode.SymbolKind[] = [
    vscode.SymbolKind.Function,
    vscode.SymbolKind.Method,
    vscode.SymbolKind.Constructor
];
