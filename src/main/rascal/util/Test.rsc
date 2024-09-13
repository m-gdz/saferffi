module util::Test

import IO;
import Map;
import Set;
import ParseTree;
import lang::rust::\syntax::Ferrocene;
import String;
import Type;
import vis::Text;

import util::Parse;


void testfn(){
    loc file = |file:///Users/potato/Developer/Projects/testproject/src/main.rs|;
    start[SourceFile] tree = parse(#start[SourceFile], file, allowAmbiguity=true);
    loc file2 = |file:///Users/potato/Developer/Projects/testproject/src/main.rs|(17,41,<1,4>,<1,45>);
    TreeSearchResult[FunctionDeclaration] searchResult = treeAt(#FunctionDeclaration, file2 , tree);
    Tree subtree;
    if (treeFound(FunctionDeclaration foundTree) := searchResult) subtree = foundTree;
	else throw "The given position (loc) is not found in the tree";  
    println(prettyTree(subtree));
}