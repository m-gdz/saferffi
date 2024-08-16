module util::Wrap

import IO;
import Map;
import Set;
import ParseTree;
import lang::rust::\syntax::Ferrocene;
import String;


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
             new_items := convert(repacked_fns),
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
            fnds += t;
        }
        case t: (FunctionDeclaration) `fn <Name name>()<ReturnType rt>;` :{
            fnds += t;
        }
        case t: (FunctionDeclaration) `fn <Name name>(<FunctionParameterList fpl>)<ReturnType rt>;` :{
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

ExternItem* find_extern_blocks(Item item){

    top-down visit(items){
        case (Item) `extern "C" {
                    '<InnerAttributeOrDoc* attrs>
                    '<ExternItem* fns>
                    '}` :{
            ExternItem* wrapped_fns = wrap_fns(fns);
            insert (Item) `extern "C" {
                    '<InnerAttributeOrDoc* attrs>
                    '<ExternItem* wrapped_fns>
                    '}`;
        }
    }
    return items;
}



// Item* insert_item(Item first, Item* tail) = (Items) `<Item first><Item* tail>`.items;

// Item* append_item(Item* prefix, Item* postfix) = (Items) `<Item* prefix><Item* postfix>`.items;

Item* convert(list[Item] itemList) { 
    itemStr = intercalate("\n", [ "<item>" | item <- itemList ]); 
    Items itemC = [Items] itemStr; 
    return itemC.items; 
}

Item* implement(Item* items, list[FunctionDeclaration] extern_fns) = visit(items){
    case (FunctionDeclaration) `fn <Name name>();` :{
            Name n = [Name] "safe_<name>";
            Expression body = [Expression] "unsafe {<name>_1();}";
            insert (FunctionDeclaration) `fn <Name n>(){<Expression body>}`;
        }
    case (FunctionDeclaration) `fn <Name name>(<FunctionParameterList fpl>);` :{
            Name n = [Name] "safe_<name>";
            ArgumentOperandList args = params_to_arguments(fpl);
            Expression body = [Expression] "unsafe {<name>_2(<args>);}";
            insert (FunctionDeclaration) `fn <Name n>(<FunctionParameterList fpl>){<Expression body>}`;
    }
    case (FunctionDeclaration) `fn <Name name>() <ReturnType rt>;` :{
            Name n = [Name] "safe_<name>";
            Expression body = [Expression] "unsafe {<name>_3();}";
            insert (FunctionDeclaration) `fn <Name n>() <ReturnType rt> {<Expression body>}`;
    }
    case (FunctionDeclaration) `fn <Name name>(<FunctionParameterList fpl>)<ReturnType rt>;` :{
            Name n = [Name] "safe_<name>";
            ArgumentOperandList args = params_to_arguments(fpl);
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

ArgumentOperandList params_to_arguments(FunctionParameterList fpl){
    list[str] params = [];
    visit(fpl){
        case(FunctionParameterPattern) `<PatternWithoutAlternation pattern> :<TypeSpecification typ>` :{
            params += extract_id(pattern);
        }
    }
    return [ArgumentOperandList] intercalate(", ", params);
} 

str extract_id(PatternWithoutAlternation pattern){
    str raw_pattern = unparse(pattern);
    return raw_pattern;
}


