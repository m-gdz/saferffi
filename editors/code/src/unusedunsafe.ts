import * as vscode from 'vscode';
import * as fs from 'fs';
import { locationToString } from './utils';

export function findUnnecessaryUnsafeBlocks() {
    const allDiagnostics = vscode.languages.getDiagnostics();
    const unnecessaryUnsafeBlocks = [];

    for (const [uri, diagnostics] of allDiagnostics) {
        const document = vscode.workspace.textDocuments.find(doc => doc.uri.toString() === uri.toString());
        if (!document) continue;

        for (const diagnostic of diagnostics) {
            if (diagnostic.message.startsWith("unnecessary `unsafe` block")) {
                const range = diagnostic.range;
                const location = locationToString(uri, range, document);
                unnecessaryUnsafeBlocks.push(location);
            }
        }
    }

    return unnecessaryUnsafeBlocks;
}
export function saveUnnecessaryUnsafeBlocksToDisk(result: any[], filePath: string) {
    const json = JSON.stringify(result);
    fs.writeFileSync(filePath, json);
}