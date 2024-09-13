module util::ControlFlow

data FunctionDeclaration
    = entry(loc location)
    | calls(list[loc] locations);

    