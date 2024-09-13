module util::Wrap

import IO;
import Map;
import Set;
import ParseTree;
import lang::rust::\syntax::Ferrocene;
import String;
import Type;


start[SourceFile] wrap2(start[SourceFile] file){
    println("Wrapping functions");
    file = top-down visit(file){
        case (SourceFile) `<InnerAttributeOrDoc* attrs>
                          '<Item* items>` =>
             (SourceFile) `<InnerAttributeOrDoc* attrs>
                          '<Item* items>
                          '<Item* newer_items>`
        when fns := extract_fns(items), 
             repacked_fns := repack_fns(fns),
             new_items := convert_items(repacked_fns),
             newer_items := implement(new_items, fns)

    }
    return file;
}

list[FunctionDeclaration] extract_fns(Item* fns){
    println("Extracting functions");
    list[FunctionDeclaration] fnds = [];
    top-down visit(fns){
        case t: (FunctionDeclaration) `fn <Name name>();` :{
            fnds += t;
        }
        case t: (FunctionDeclaration) `fn <Name name>(<FunctionParameterList fpl>);` :{
            println(t);
            fnds += t;
        }
        case t: (FunctionDeclaration) `fn <Name name>()<ReturnType rt>;` :{
            println(t);
            fnds += t;
        }
        case t: (FunctionDeclaration) `fn <Name name>(<FunctionParameterList fpl>)<ReturnType rt>;` :{
            println(t);
            fnds += t;
        }
    }
    return fnds;
}

list[Item] repack_fns(list[FunctionDeclaration] fns){
    list[Item] new_items = [];
    for (fn <- fns){
        Item item = repack(fn);
        new_items += item;
    }
    return new_items;
}

Item repack(FunctionDeclaration fn){
    raw_fn = unparse(fn);
    println("Repacking function: <raw_fn>");
    return [Item] raw_fn;
}



// Item* insert_item(Item first, Item* tail) = (Items) `<Item first><Item* tail>`.items;

// Item* append_item(Item* prefix, Item* postfix) = (Items) `<Item* prefix><Item* postfix>`.items;

Item* convert_items(list[Item] itemList) { 
    itemStr = intercalate("\n", [ "<item>" | item <- itemList ]); 
    Items itemC = [Items] itemStr; 
    return itemC.items; 
}

Statement* convert_stmts(list[Statement] stmtList) { 
    stmtStr = intercalate("\n", [ "<stmt>" | stmt <- stmtList ]); 
    Statements stmtC = [Statements] stmtStr; 
    return stmtC.statements; 
}

Item* implement(Item* items, list[FunctionDeclaration] extern_fns) = visit(items){
    case (FunctionDeclaration) `fn <Name name>();` :{
            Name n = [Name] "safe_<name>";
            Expression body = [Expression] "unsafe {<name>_1();}";
            insert (FunctionDeclaration) `fn <Name n>(){<Expression body>}`;
        }
    case (FunctionDeclaration) `fn <Name name>(<FunctionParameterList fpl>);` :{
            Name n = [Name] "safe_<name>";
            <fpl2, args, stmts>  = rename_underscore_args(fpl);
            Expression body = [Expression] "unsafe { <name>(<args>); }";
            insert (FunctionDeclaration) `fn <Name n>(<FunctionParameterList fpl2>){
                '    <Statement* stmts>
                '    <Expression body>
                '}`;
    }
    case (FunctionDeclaration) `fn <Name name>() <ReturnType rt>;` :{
            Name n = [Name] "safe_<name>";
            Expression body = [Expression] "unsafe {<name>_3();}";
            insert (FunctionDeclaration) `fn <Name n>() <ReturnType rt> {<Expression body>}`;
    }
    case (FunctionDeclaration) `fn <Name name>(<FunctionParameterList fpl>)<ReturnType rt>;` :{
            Name n = [Name] "safe_<name>";
            <fpl2, args, stmts>  = rename_underscore_args(fpl);
            //ArgumentOperandList args = params_to_arguments(fpl);
            Expression body = [Expression] "unsafe {<name>_4(<args>);}";
            insert (FunctionDeclaration) `fn <Name n>(<FunctionParameterList fpl>) <ReturnType rt> {<Expression body>}`;
    }
};


// ArgumentOperandList convert_params(FunctionParameterList fpl) = visit(fpl){
//     case (FunctionParameter) `` :{
//     }
// };


// list[tuple[Identifier, TypeSpecification]] extract_parameters(FunctionParameterList fpl){
//     list[tuple[Identifier, TypeSpecification]] params = [];
//     visit(fpl){
//         case(FunctionParameterPattern) `<PatternWithoutAlternation pattern> :<TypeSpecification typ>` :{
//             params += <extract_id(pattern), typ>;
//         }
//     }
//     return params;
// } 

tuple[FunctionParameterList, ArgumentOperandList, Statement*] rename_underscore_args(FunctionParameterList fpl){
    int i = 0;
    list[Statement] stmts = [];
    list[str] params = [];

    // Here we are removing the variadic part of the function, as it not supported as is in Rust
    fpl = visit(fpl){
        case(FunctionParameterList) `<{FunctionParameter ","}+ prms>, _: ...` => 
            (FunctionParameterList) `<{FunctionParameter ","}+ prms>`
    }
    fpl = visit(fpl){
        case(FunctionParameterPattern) `_: <TypeSpecification typ>` :{ // Instead of underscore, we could match <PatternWithoutAlternation pattern>
            str arg_name = "arg<i>";
            TypeSpecification typ2 = visit(typ){
                case (TypeSpecification) `*const libc::c_char`: {
                    stmts += [Statement] "let <arg_name>_c = std::ffi::CString::new(arg<i>).expect(\"Failed to convert to C string\");";
                    stmts += [Statement] "let <arg_name>_ptr = arg<i>_c.as_ptr();";
                    arg_name = "<arg_name>_ptr";
                    insert (TypeSpecification) `&str`;
                }
            };
            PatternWithoutAlternation p = [PatternWithoutAlternation] "arg<i>";
            params += arg_name;
            i += 1;
            insert (FunctionParameterPattern) `<PatternWithoutAlternation p>: <TypeSpecification typ2>`;
        }
    }
    ArgumentOperandList args = [ArgumentOperandList] intercalate(", ", params);
    return <fpl, args, convert_stmts(stmts)>;
} 


// ArgumentOperandList params_to_arguments(FunctionParameterList fpl){
//     list[str] params = [];
//     visit(fpl){
//         case(FunctionParameterPattern) `<PatternWithoutAlternation pattern> :<TypeSpecification typ>` :{
//             params += extract_id(pattern);
//         }
//     }
//     return [ArgumentOperandList] intercalate(", ", params);
// } 

str extract_id(PatternWithoutAlternation pattern){
    str raw_pattern = unparse(pattern);
    return raw_pattern;
}



