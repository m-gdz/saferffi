module util::Config

import IO;
import Map;
import Set;
import ParseTree;
import lang::rust::\syntax::TOMLLayout;

start[TOML] addBindgen(start[TOML] toml){
    toml = top-down visit(toml){
        case (Section) `[dependencies]
                    '<Keyval* keyvals>` =>
             (Section) `[dependencies]
                    'bindgen = "0.1.0"
                    '<Keyval* keyvals>`
        when /(SimpleKey) `bindgen` !:= keyvals
    }
    return toml;
}
 