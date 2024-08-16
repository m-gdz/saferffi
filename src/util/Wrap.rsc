module util::Wrap

import IO;
import Map;
import Set;
import ParseTree;
import lang::rust::\syntax::Ferrocene;
import String;



// start[SourceFile] wrap(start[SourceFile] file){
//     file = top-down visit(file){
//         case (Item) `extern "C" {
//                     '<InnerAttributeOrDoc* attrs>
//                     '<ExternItem* fns>
//                     '}` =>
//              (Item) `extern "C" {
//                     '<InnerAttributeOrDoc* attrs>
//                     '<ExternItem* wrapped_fns>
//                     '}`
//         when wrapped_fns := wrap_fns(fns)
//     }
//     return file;
// }



// list[Item] wrap_fns(ExternItem* fns){
//     list[Item] new_items = [];
//     fns = top-down visit(fns){
//         case t: (FunctionDeclaration) `fn <Name name>();` :{
//             new_items += [t];
//             Name n = [Name] "safe_<name>";
//             insert (FunctionDeclaration) `fn <Name n>();`;
//         }
//         case (FunctionDeclaration) `fn <Name name>(<FunctionParameterList fpl>);` :{
//             Name n = [Name] "safe_<name>";
//             insert (FunctionDeclaration) `fn <Name n>(<FunctionParameterList fpl>);`;
//         }
//         case (FunctionDeclaration) `fn <Name name>() <ReturnType rt> ;` :{
//             Name n = [Name] "safe_<name>";
//             insert (FunctionDeclaration) `fn <Name n>() <ReturnType rt>;`;
//         }
//         case (FunctionDeclaration) `fn <Name name>(<FunctionParameterList fpl>) <ReturnType rt>;` :{
//             Name n = [Name] "safe_<name>";
//             insert (FunctionDeclaration) `fn <Name n>(<FunctionParameterList fpl>) <ReturnType rt>;`;
//         }

//     }
//     return new_items;
// }


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



Item* insert_item(Item first, Item* tail) = (Items) `<Item first><Item* tail>`.items;

Item* append_item(Item* prefix, Item* postfix) = (Items) `<Item* prefix><Item* postfix>`.items;

Item* convert(list[Item] idList) { 
    idStr = intercalate("\n", [ "<id>" | id <- idList ]); 
    Items idC = [Items] idStr; 
    return idC.items; 
}

Item* implement(Item* items, list[FunctionDeclaration] extern_fns) = visit(items){
    case fn: (FunctionDeclaration) `fn <Name name>();` : {
                    println("found one");
                    Name n = [Name] "safe_<name>";
                    insert (FunctionDeclaration) `fn <Name n>(){}`;
              }
};
