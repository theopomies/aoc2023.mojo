from builtin.string import isdigit
from utils.static_tuple import StaticTuple

from helpers.io import read_file
from helpers.vector import map_vector, reduce_vector, sum


fn day1(args: VariadicList[StringRef]) raises:
    let input_file_name = args[1]
    let input_file_lines = read_file(input_file_name).split("\n")

    print("Part1:", part1(input_file_lines))
    print("Part2:", part2(input_file_lines))


fn part1(lines: DynamicVector[String]) raises -> Int:
    return compute_lines_sum(lines, True)


fn part2(lines: DynamicVector[String]) raises -> Int:
    return compute_lines_sum(lines, False)


fn compute_lines_sum(lines: DynamicVector[String], only_numeric: Bool) raises -> Int:
    var total = 0
    for i in range(len(lines)):
        let line = lines[i]
        var first = 0
        var last = 0
        var value = 0

        for i in range(len(line)):
            let substr = line[i : i + 5]

            if value := str_to_i(substr, only_numeric):
                if not first:
                    first = value
                else:
                    last = value

        total += first * 10 + (last or first)

    return total


fn str_to_i(str: String, only_numeric: Bool) raises -> Int:
    let digit_strings = StaticTuple[9](
        "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"
    )
    if isdigit(str._buffer[0]):
        return atol(str[0])

    if only_numeric:
        return 0

    for i in range(digit_strings.__len__()):
        let digit = digit_strings[i]
        if str[: len(digit)] == digit:
            return i + 1

    return 0
