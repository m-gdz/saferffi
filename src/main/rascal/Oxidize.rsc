module Oxidize

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
import util::RemoveUnsafe;
import util::Config;

import util::Maybe;

import util::Refactor;

import lang::rust::\syntax::Ferrocene;

// public void main(list[str] args){
// 	str usage = "usage: Oxidize.rsc [-v] [-c /\<path-from-root\>/\<callgraph\>] /\<path-from-root\>/\<target\>";
//     str insufficient_parameters = "Error: No project root path provided. Please consult the usage guide.";
// 	str insufficient_parameters_cg = "Error: No callgraph path provided. Please consult the usage guide.";
    
    
//     // Variables for options
//     loc callgraph_path = |unknown:///|;
//     loc project_path = |unknown:///|;
//     bool verbose = false;

//     int i = 0;
//     while (i < size(args)) {
//         switch (args[i]) {
//             case /-v/: {
//                 verbose = true;
//                 i += 1;
//             }
//             case /-c/: {
// 				try{
// 					loc target = |file:///| + args[i + 1];
// 					if(exists(target)){
// 						callgraph_path = target;
// 					}
// 					i += 2;
// 				} catch IndexOutOfBounds(int i): {
// 					println(insufficient_parameters_cg);
// 					break;
// 				} catch EmptyList(): {
// 					println(insufficient_parameters_cg);
// 					break;
// 				}
//             }
//             default: {
// 				try{
// 					loc target = |file:///| + args[i];
// 					if(exists(target) && isDirectory(target)){
// 						project_path = target;
// 					}
// 					i += 1;
// 				} catch IndexOutOfBounds(int i): {
// 					println(insufficient_parameters);
// 					break;
// 				} catch EmptyList(): {
// 					println(insufficient_parameters);
// 					break;
// 				}
// 			}
//         }
//     }

// 	parseCallGraph(callgraph_path);
// 	println(project_path.path);
// }

public void main(list[str] args) {
    // Usage messages
    str usage = "Usage: saferffi [OPTIONS] COMMAND [ARGS]...\n"
          + "\n"
          + "Options:\n"
          + "  -v, --verbose     Enable verbose mode.\n"
          + "  -h, --help        Show help information.\n"
          + "\n"
          + "Commands:\n"
          + "  config            Perform configuration refactoring (no additional input required).\n"
          + "  removeunsafe      Remove unsafe code using a provided unsafe.json file.\n"
          + "  wrap              Wrap code using a provided callgraph.json file.\n";


    str insufficient_parameters = "Error: No project root path provided. Please consult the usage guide.";
    str missing_command = "Error: No command provided. Use config, removeunsafe, or wrap.";
    str invalid_command = "Error: Invalid command provided. Please consult the usage guide.";
    str missing_unsafe_file = "Error: No unsafe.json file provided for removeunsafe command.";
    str missing_callgraph_file = "Error: No callgraph.json file provided for wrap command.";

    // Variables for options and arguments
    loc callgraph_path = |unknown:///|;
    loc unsafe_json_path = |unknown:///|;
    loc project_path = |unknown:///|;
    bool verbose = false;
    str command = "";
    
    int i = 0;

    // Check for options (-v or --verbose)
    while (i < size(args)) {
        switch (args[i]) {
            case /-v/: {
                verbose = true;
                i += 1;
            }
            case /-h/: {
                println(usage);
                return;
            }
            default: {
                command = args[i];
                i += 1;
                break;
            }
        }
    }

    // Ensure a command is provided
    if (command == "") {
        println(missing_command);
        println(usage);
        return;
    }

    // Handle commands
    switch (command) {
        case /config/: {
            // Handle config command (no additional arguments needed)
            if (i >= size(args)) {
                println(insufficient_parameters);
                return;
            }
            loc target = |file:///| + args[i];
            if (exists(target) && isDirectory(target)) {
                project_path = target;
            } else {
                println(insufficient_parameters);
                return;
            }
            // Execute config refactoring logic here
            println("Config refactoring on project: " + project_path.path);
        }
        case /removeunsafe/: {
            // Handle removeunsafe command (requires unsafe.json and project path)
            if (i + 1 >= size(args)) {
                println(missing_unsafe_file);
                return;
            }
            loc unsafe_target = |file:///| + args[i];
            if (exists(unsafe_target)) {
                unsafe_json_path = unsafe_target;
            } else {
                println(missing_unsafe_file);
                return;
            }
            loc target = |file:///| + args[i + 1];
            if (exists(target) && isDirectory(target)) {
                project_path = target;
            } else {
                println(insufficient_parameters);
                return;
            }
            // Execute removeunsafe logic here
            println("Removing unsafe code using: " + unsafe_json_path.path);
            println("On project: " + project_path.path);
			Oxidize(project_path, unsafe_json=unsafe_json_path, command="removeunsafe", verbose=verbose);
        }
        case /wrap/: {
            // Handle wrap command (requires callgraph.json and project path)
            if (i + 1 >= size(args)) {
                println(missing_callgraph_file);
                return;
            }
            loc callgraph_target = |file:///| + args[i];
            if (exists(callgraph_target)) {
                callgraph_path = callgraph_target;
            } else {
                println(missing_callgraph_file);
                return;
            }
            loc target = |file:///| + args[i + 1];
            if (exists(target) && isDirectory(target)) {
                project_path = target;
            } else {
                println(insufficient_parameters);
                return;
            }
            // Execute wrap logic here
            println("Wrapping code using: " + callgraph_path.path);
            println("On project: " + project_path.path);
			Oxidize(project_path, callgraph=callgraph_path, command="wrap", verbose=verbose);
        }
        default: {
            println(invalid_command);
            println(usage);
        }
    }
}



public Maybe[map[str, list[loc]]] parseCallGraph(loc callgraph){
	try {
		map[str, list[loc]] callGraph = readJSON(#map[str, list[loc]], callgraph);
		return just(callGraph);
	} catch ParseError(e): {
		println("Error while parsing JSON");
        return nothing();
	}
}


public Maybe[list[loc]] parseUnnecessaryUnsafeBlocks(loc file) {
    try {
        list[loc] unnecessaryUnsafeBlocks = readJSON(#list[loc], file);
        return just(unnecessaryUnsafeBlocks);
    } catch ParseError(e): {
        println("Error while parsing unsafe.json");
        return nothing();
    }
}



public void Oxidize(loc project_loc, str extension=".rs", loc callgraph = |unknown:///|, loc unsafe_json = |unknown:///|, str command="", bool verbose=false) {
    datetime timer_start = now();
    
    // Step 1: Walk the project directory
    list[loc] source_locs = Walk(project_loc, extension);
    
    // Step 2: Parse the source files
    list[Tree] source_trees = Parse(source_locs, verbose=verbose);
    
    // Step 3: Delegate to the appropriate refactoring strategy
    switch (command) {
        case "wrap": {
            refactorWrap(source_trees, project_loc, callgraph, verbose);
        }
        case "removeunsafe": {
            refactorRemoveUnsafe(source_trees, project_loc, unsafe_json, verbose);
        }
        case "config": {
            refactorConfig(source_trees, project_loc, verbose);
        }
        default: {
            println("Unknown command: " + command);
        }
    }
    
    // Print elapsed time
    Duration timer_duration = createDuration(timer_start, now());
    println(Timer(timer_duration));
}


// ### Refactoring Strategies ###

// Refactoring strategy for "wrap"
public void refactorWrap(list[Tree] source_trees, loc project_loc, loc callgraph, bool verbose) {
	if(verbose){
    	println("Running wrap refactoring...");
	}
    int count = 0;
    map[loc, FunctionDeclaration] wrapped_fns = ();
    map[loc, Tree] wrapped_trees = ();
	for(st <- source_trees){
	
		if(verbose){
			count += 1;
			print("\rProcessing file <count> out of <size(source_trees)>...");
		}
	
        str project_path = project_loc.path;
		str file_path = st@\loc.path;
		
		str new_project_path = (project_loc.parent + (project_loc.file + "_idiom/")).path;
		loc new_file_path = |file:///| + replaceFirst(file_path, project_path, new_project_path);
		
		

		<tree, loc2fn> = wrap2(st);
        wrapped_fns += loc2fn;
        wrapped_trees += (new_file_path: tree);

		
	}
	if(verbose){
		print("\n");
	}

    Maybe[map[str, list[loc]]] maybeCallGraph = parseCallGraph(callgraph);

    switch(maybeCallGraph){
        case just(map[str, list[loc]] callGraph): {
            for (file_path <- wrapped_trees){
                Tree st = refactorCalls(wrapped_trees[file_path], callGraph, wrapped_fns);
	            writeFile(file_path, st);
            }
        }
        case nothing(): {
            println("Aborting refactor because parsing callgraph failed.");
        }
    }

    // for (st <- wrapped_trees){

    //     othertest(st, parseCallGraph(callgraph), wrapped_fns);

    //     // str project_path = project_loc.path;
	// 	// str file_path = st@\loc.path;
		
	// 	// str new_project_path = (project_loc.parent + (project_loc.file + "_idiom/")).path;
	// 	// loc new_file_path = |file:///| + replaceFirst(file_path, project_path, new_project_path);
		
		
	// 	// writeFile(new_file_path, wrap);
    // }

}

// Refactoring strategy for "removeunsafe"
public void refactorRemoveUnsafe(list[Tree] source_trees, loc project_loc, loc unsafe_json, bool verbose) {
    if (verbose) {
        println("Running removeunsafe refactoring...");
    }

    // Attempt to parse the unsafe.json file
    Maybe[list[loc]] maybeUnsafeBlocks = parseUnnecessaryUnsafeBlocks(unsafe_json);

    // Handle the result of the Maybe
    switch (maybeUnsafeBlocks) {
        case just(list[loc] unsafe_blocks): {
            int count = 0;
            for (st <- source_trees) {
                if (verbose) {
                    count += 1;
                    print("\rProcessing file <count> out of <size(source_trees)>...");
                }

                str project_path = project_loc.path;
                str file_path = st@\loc.path;

                str new_project_path = (project_loc.parent + (project_loc.file + "_idiom/")).path;
                loc new_file_path = |file:///| + replaceFirst(file_path, project_path, new_project_path);

                Tree wrap = removeunsafe(st, unsafe_blocks);

                writeFile(new_file_path, wrap);
            }

            if (verbose) {
                print("\n");
            }
        }
        case nothing(): {
            println("Aborting refactor because parsing unsafe.json failed.");
        }
    }
}


// Refactoring strategy for "config"
public void refactorConfig(list[Tree] source_trees, loc project_loc, bool verbose) {
    if (verbose) {
			println("Running config refactoring...");
	}
	int count = 0;
	for(st <- source_trees){
	
			if(verbose){
					count += 1;
					print("\rProcessing file <count> out of <size(source_trees)>...");
			}
	
			str project_path = project_loc.path;
			str file_path = st@\loc.path;
			
			str new_project_path = (project_loc.parent + (project_loc.file + "_configured/")).path;
			loc new_file_path = |file:///| + replaceFirst(file_path, project_path, new_project_path);
			
			Tree toml = addBindgen(st);
			writeFile(new_file_path, toml);
	}
	if(verbose){
			print("\n");
	}

  

}


