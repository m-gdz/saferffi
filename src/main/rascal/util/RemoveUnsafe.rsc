module util::RemoveUnsafe


import IO;
import Map;
import Set;
import ParseTree;
import lang::rust::\syntax::Ferrocene;
import String;
import Type;


start[SourceFile] removeunsafe(start[SourceFile] file, list[loc] unused_unsafe_blocks){
    file = top-down visit(file){
        case t: (ExpressionWithBlock) `unsafe <BlockExpression expr>` => 
                (ExpressionWithBlock) `<BlockExpression expr>`
        when hasOffset(unused_unsafe_blocks, t.src.offset)
    }
    return file;
}

bool hasOffset(list[loc] locs, int offset) {
    for (loc l <- locs) {
        if (l.offset == offset) {
            return true;
        }
    }
    return false;
}