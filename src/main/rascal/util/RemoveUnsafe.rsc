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
        when isUnnecessary(t.src.offset, unused_unsafe_blocks)
    }
    return file;
}

bool isUnnecessary(int offset, list[loc] locs) {
    for (loc l <- locs) {
        if (l.offset == offset) {
            return true;
        }
    }
    return false;
}