from sys import argv
from builtin.string import isdigit
from utils.static_tuple import StaticTuple

from helpers.string import read_file, split_lines_to_slices, Slices
from helpers.vector import map_vector, reduce_vector, sum


fn day1() raises:
    let input_file_name = argv()[1]
    let input_file = read_file(input_file_name)
    let input_file_lines_slices = split_lines_to_slices(input_file)

    print("Part1:", part1(input_file, input_file_lines_slices))
    print("Part2:", part2(input_file, input_file_lines_slices))


fn part1(input_file: String, input_file_lines_slices: Slices) raises -> Int:
    @parameter
    fn line_mapper(line_slice: slice) raises -> Int:
        let line = input_file[line_slice]

        var first: String = ""
        var last: String = ""

        for i in range(len(line)):
            let candidate = line[i]

            if isdigit(candidate._buffer[0]):
                if not first:
                    first = candidate
                else:
                    last = candidate

        return atol(first + (last or first))

    let values = map_vector[slice, Int](input_file_lines_slices, line_mapper)
    return reduce_vector[Int, Int](values, 0, sum)


fn part2(input_file: String, input_file_lines_slices: Slices) raises -> Int:
    @parameter
    fn line_mapper(line_slice: slice) raises -> Int:
        let line = input_file[line_slice]

        var first = 0
        var last = 0
        var value = 0

        for i in range(len(line)):
            let substr = line[i : i + 5]

            if value := str_to_i(substr):
                if not first:
                    first = value
                else:
                    last = value

        return first * 10 + (last or first)

    let values = map_vector[slice, Int](input_file_lines_slices, line_mapper)
    return reduce_vector[Int, Int](values, 0, sum)


fn str_to_i(str: String) raises -> Int:
    let digit_strings = StaticTuple[9](
        "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"
    )
    if isdigit(str._buffer[0]):
        return atol(str[0])

    for i in range(digit_strings.__len__()):
        let digit = digit_strings[i]
        if str[: len(digit)] == digit:
            return i + 1

    return 0
