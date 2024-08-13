module util::Config

import IO;
import Map;
import Set;
import ParseTree;
import lang::rust::\syntax::TOML;

start[TOML] config(start[TOML] toml){
    toml = top-down visit(toml){
        case (TOML) `[dependencies]`: println("Found dependencies table");
    }
    return toml;
}