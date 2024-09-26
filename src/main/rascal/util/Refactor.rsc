module util::Refactor

import IO;
import Map;
import Set;
import ParseTree;
import lang::rust::\syntax::Ferrocene;
import String;
import Type;
import vis::Text;
import Location;

import util::Maybe;
import util::Parse;

import ValueIO;
import lang::rust::\syntax::Ferrocene;


start[SourceFile] refactorCalls(start[SourceFile] sourceFile, map[str, list[loc]] refMap, map[loc, FunctionDeclaration] wrappedFunctions) {
    map[loc, loc] flattenedRefMap = flattenRefMap(refMap);

    return top-down visit(sourceFile) {
        case t: (CallExpression) `<CallOperand operand>(<ArgumentOperandList args>)` : {
            loc fnDeclaration = findCallInGraph(operand.src, flattenedRefMap);
            if (fnDeclaration != |unknown:///|) {
                Maybe[FunctionDeclaration] maybeFn = getFunctionDeclaration(fnDeclaration, wrappedFunctions);
            
                if (!(maybeFn is nothing)) {

                    // println("Found a call to a wrapped function: <unparse(maybeFn.val)>");
                    // println(args);
                    ArgumentOperandList newArgs = updateArguments(args, maybeFn.val);
                    CallOperand newOperand = renameCall(operand);
                    insert (CallExpression) `<CallOperand newOperand>(<ArgumentOperandList newArgs>)`;
                }
            }
        }
    }
}

CallOperand renameCall(CallOperand operand) {
    str operandRaw = unparse(operand);
    operandRaw = operandRaw + "_wrapped";
    return parse(#CallOperand, operandRaw);
}

loc findCallInGraph(loc location, map[loc, loc] locations) {
    for (loc l <- locations) {
        if (isContainedIn(l, location)) {
            return locations[l];
        }
    }
    return |unknown:///|;
}

Maybe[FunctionDeclaration] getFunctionDeclaration(loc location, map[loc, FunctionDeclaration] wrappedFunctions) {
    for (loc l <- wrappedFunctions) {
        if (isContainedIn(l, location)) {
            return just(wrappedFunctions[l]);
        }
    }
    return nothing();
}

map[loc, loc] flattenRefMap(map[str, list[loc]] refMap) {
    map[loc, loc] flat = ();
    for (entry <- refMap) {
        flat += (location : readTextValueString(#loc, entry) | location <- refMap[entry]);
    }
    return flat;
}

ArgumentOperandList updateArguments(ArgumentOperandList args, FunctionDeclaration fn_decl) = top-down visit(args) {
    case (Expression) `<ByteStringLiteral lit> as *const u8 as *const libc::c_char` : {
        Expression string = [Expression] "\"<literalToStr(lit)>\"";
        insert (Expression) `<Expression string>`;
    }
};

str literalToStr(ByteStringLiteral literal) {
    str literalStr = unparse(literal);
    literalStr = literalStr[2..-1];  // Remove the initial "b\" and trailing quote
    if (endsWith(literalStr, "\\0")) {
        return literalStr[0..-2];  // Remove trailing null byte if present
    } else {
        return literalStr;
    }
}
