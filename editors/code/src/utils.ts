import * as vscode from 'vscode';

export function locationToString(uri: vscode.Uri, range: vscode.Range, document: vscode.TextDocument): string {
    const offset = document.offsetAt(range.start);
    const length = document.offsetAt(range.end) - offset;
    const beginLine = range.start.line; // Apparently, Rascal uses 1-based line numbers
    const beginColumn = range.start.character;
    const endLine = range.end.line;
    const endColumn = range.end.character;

    return `|${uri.toString()}|(${offset},${length},<${beginLine},${beginColumn}>,<${endLine},${endColumn}>)`;
}
export function normalizedPath(path: string): string {
    return process.platform === 'win32' ? path.replace(/^\/\w+(?=:)/, drive => drive.toUpperCase()) : path;
}