from helpers.collections import NaiveMap, StringKey


@value
struct Node(CollectionElement, Stringable):
    var left: String
    var right: String

    @staticmethod
    fn get_from_input_lines(
        input_lines: DynamicVector[String],
    ) raises -> NaiveMap[StringKey, Self]:
        var map = NaiveMap[StringKey, Node](capacity=len(input_lines) - 2)

        for i in range(2, len(input_lines)):
            let split_line = input_lines[i].split(" = ")
            map[split_line[0]] = Self.from_string(split_line[1])

        return map

    @staticmethod
    fn from_string(input_line: String) raises -> Self:
        """Returns a Self instance based on a left, right node.

        Args:
            input_line: String in the format "(left, right)".
        """
        let split = input_line[1:-1].split(", ")
        return Self(left=split[0], right=split[1])

    fn __str__(self) -> String:
        return "(left=" + self.left + ", right=" + self.right + ")"


fn day8(args: VariadicList[StringRef]) raises:
    let file_input_lines = Path(args[1]).read_text().split("\n")
    let instructions = file_input_lines[0]
    let map = Node.get_from_input_lines(file_input_lines)
    print("Part1:", part1(instructions, map))
    print("Part2:", part2(instructions, map))


fn part1(instructions: String, map: NaiveMap[StringKey, Node]) raises -> Int:
    let instructions_len = len(instructions)
    var current_node = map["AAA"]
    var i = 0

    while True:
        let instuction = instructions[i % instructions_len]
        let key: String
        if instuction == "L":
            key = current_node.left
        else:
            key = current_node.right
        i += 1
        if key == "ZZZ":
            return i
        current_node = map[key]


fn part2(instructions: String, map: NaiveMap[StringKey, Node]) raises -> Int:
    let map_keys = map.keys()
    var cycles = DynamicVector[Int](capacity=len(map_keys))

    for i in range(len(map_keys)):
        let key = map_keys[i]
        if key[2] == "A":
            cycles.push_back(get_keys_cycle(key, instructions, map))

    var lcm = cycles[0]
    for i in range(1, len(cycles)):
        lcm = least_common_multiple(lcm, cycles[i])
    return lcm


fn get_keys_cycle(
    beg_key: String, instructions: String, map: NaiveMap[StringKey, Node]
) raises -> Int:
    let instructions_len = len(instructions)
    var instruction_index = 0
    var key = beg_key

    while True:
        let instruction = instructions[instruction_index % instructions_len]
        if instruction == "L":
            key = map[key].left
        else:
            key = map[key].right
        instruction_index += 1
        if key[2] == "Z":
            return instruction_index


fn least_common_multiple(a: Int, b: Int) -> Int:
    return a * b // greatest_common_divisor(a, b)


fn greatest_common_divisor(a: Int, b: Int) -> Int:
    var _a = a
    var _b = b
    while _b != 0:
        let t = _b
        _b = _a % _b
        _a = t
    return _a
