alias Slices = DynamicVector[slice]

alias CallbackWithIndex = fn (string: String, index: Int) raises capturing -> NoneType
alias Callback = fn (string: String) raises capturing -> NoneType


fn read_file(file_name: StringRef) raises -> String:
    let file_content: String

    with open(file_name, "r") as file:
        file_content = file.read()

    return file_content


fn split_lines_to_slices(base: String) -> Slices:
    return split_to_slices(base, "\n")


fn split_to_slices(base: String, at: String) -> Slices:
    let size = base.count(at) + 1
    var slices = Slices()
    var start = 0
    let end: Int
    let offset = len(at)

    while (end := base.find(at, start)) != -1:
        slices.push_back(slice(start, start + end))
        start += end + offset
    slices.push_back(slice(start, len(base)))

    return slices


fn for_each_string_slice(base: String, slices: Slices, callback: Callback) raises:
    for i in range(len(slices)):
        callback(base[slices[i]])


fn for_each_string_slice(
    base: String, slices: Slices, callback: CallbackWithIndex
) raises:
    for i in range(len(slices)):
        callback(base[slices[i]], i)
