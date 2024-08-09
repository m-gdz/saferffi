module Main

// Std
import IO;
import List;
import String;
import DateTime;
import ParseTree;
import Node;
import List;
import ListRelation;
import Type;
import vis::Text;


// Project
import util::Walk;
import util::Parse;
import util::Timer;

int main(int testArgument=0) {
    println("argument: <testArgument>");
    return testArgument;
}

public void SaferFFI(loc project_loc, str extension=".rs", bool verbose=false){
	datetime timer_start = now();
	
	list[loc] source_locs = Walk(project_loc, extension);
	
	list[Tree] source_trees = Parse(source_locs, verbose=verbose);

	for(st <- source_trees){
		println(prettyTree(st));
		//saveParseTreeRender(st);
	}

    Duration timer_duration = createDuration(timer_start, now());
	println(Timer(timer_duration));

}