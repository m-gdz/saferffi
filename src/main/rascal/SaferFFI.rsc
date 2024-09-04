module SaferFFI

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
import lang::json::IO;


// Project
import util::Walk;
import util::Parse;
import util::Timer;
import util::Wrap;

public void main(list[str] args){
	str usage = "usage: SaferFFI.rsc [-v] [-c /\<path-from-root\>/\<callgraph\>] /\<path-from-root\>/\<target\>";
    str insufficient_parameters = "Error: No project root path provided. Please consult the usage guide.";
	str insufficient_parameters_cg = "Error: No callgraph path provided. Please consult the usage guide.";
    
    
    // Variables for options
    loc callgraph_path = |unknown:///|;
    loc project_path = |unknown:///|;
    bool verbose = false;

    int i = 0;
    while (i < size(args)) {
        switch (args[i]) {
            case /-v/: {
                verbose = true;
                i += 1;
            }
            case /-c/: {
				try{
					loc target = |file:///| + args[i + 1];
					if(exists(target)){
						callgraph_path = target;
					}
					i += 2;
				} catch IndexOutOfBounds(int i): {
					println(insufficient_parameters_cg);
					break;
				} catch EmptyList(): {
					println(insufficient_parameters_cg);
					break;
				}
            }
            default: {
				try{
					loc target = |file:///| + args[i];
					if(exists(target) && isDirectory(target)){
						project_path = target;
					}
					i += 1;
				} catch IndexOutOfBounds(int i): {
					println(insufficient_parameters);
					break;
				} catch EmptyList(): {
					println(insufficient_parameters);
					break;
				}
			}
        }
    }

	parseCallGraph(callgraph_path);
	println(project_path.path);
}


public void parseCallGraph(loc callgraph){
	try {
		map[str, list[loc]] callGraph = readJSON(#map[str, list[loc]], callgraph);
		println(callGraph);
	} catch ParseError(e): {
		println("Error while parsing JSON");
	}
}

// work in progress
public void SaferFFI(loc project_loc, str extension=".rs", loc callgraph = |unknown:///|, bool verbose=false){
	datetime timer_start = now();
	
	list[loc] source_locs = Walk(project_loc, extension);
	
	list[Tree] source_trees = Parse(source_locs, verbose=verbose);


	int count = 0;
	for(st <- source_trees){
	
		if(verbose){
			count += 1;
			print("\rProcessing file <count> out of <size(source_trees)>...");
		}
	
		str project_path = project_loc.path;
		str file_path = st@\loc.path;
		
		str new_project_path = (project_loc.parent + (project_loc.file + "_idiom/")).path;
		loc new_file_path = |file:///| + replaceFirst(file_path, project_path, new_project_path);
		
		Tree wrap = wrap2(st);
		
		writeFile(new_file_path, wrap);
	}
	if(verbose){
		print("\n");
	}

    Duration timer_duration = createDuration(timer_start, now());
	println(Timer(timer_duration));

}

