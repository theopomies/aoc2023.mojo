fn read_file(file_name: String) raises -> String:
    let output: String
    with open(file_name, "r") as file:
        output = file.read()
    return output
