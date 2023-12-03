from math import abs

from helpers.string import read_file, split_lines_to_slices, Slices, for_each_string_slice
from helpers.vector import for_each_vector, filter_vector, reduce_vector


fn day3(args: VariadicList[StringRef]) raises:
    let input_file = read_file(args[1])
    let input_lines_slices = split_lines_to_slices(input_file)

    print("Part1:", part1(input_file, input_lines_slices))

fn part1(input_file: String, input_lines_slices: Slices) raises -> Int:
    var symbols = DynamicVector[Symbol]()
    var part_numbers = DynamicVector[PartNumber]()

    @parameter
    fn handle_line(line: String, y: Int) raises:
        let length = len(line)
        var x = 0
        let value: Int

        while x < length:
            let candidate = line[x:]

            if value := str_to_i(candidate):
                let offset = len(value)
                part_numbers.push_back(PartNumber {
                    pos: Position {
                        x_beg: x,
                        x_end: x + offset - 1,
                        y: y
                    },
                    value: value
                })
                x += offset
                continue
            elif Symbol.is_symbol(candidate):
                symbols.push_back(Symbol {
                    pos: Position {
                        x_beg: x,
                        x_end: x,
                        y: y
                    }
                })
            x += 1

    for_each_string_slice(input_file, input_lines_slices, handle_line)

    @parameter
    fn is_valid_part(pn: PartNumber) -> Bool:
        @parameter
        fn is_adjacent_symbol(symbol: Symbol) -> Bool:
            return pn.is_adjacent(symbol.pos)

        let adjacent_symbols = filter_vector(symbols, is_adjacent_symbol)
         
        return len(adjacent_symbols) > 0


    let valid_part_numbers = filter_vector(part_numbers, is_valid_part)

    fn sum_part_number(pn: PartNumber, acc: Int) -> Int:
        return acc + pn.value


    return reduce_vector(valid_part_numbers, 0, sum_part_number)

@register_passable("trivial")
struct Symbol:
    var pos: Position

    @staticmethod
    fn is_symbol(candidate: String) -> Bool:
        let candidate_char = candidate[0] 

        return not isdigit(candidate_char._buffer[0]) and candidate_char != "."


@register_passable("trivial")
struct Position:
    var x_beg: Int
    var x_end: Int
    var y: Int


@register_passable("trivial")
struct PartNumber:
    var value: Int
    var pos: Position

    fn is_adjacent(self, pos: Position) -> Bool:
        let is_close_verticaly = abs(self.pos.y - pos.y) <= 1
        let is_close_horizontaly = 
            self.pos.x_beg - 1 <= pos.x_beg <= self.pos.x_end + 1
            or self.pos.x_beg - 1 <= pos.x_end <= self.pos.x_end + 1

        return is_close_verticaly and is_close_horizontaly

fn str_to_i(string: String) raises -> Int:
    var end = 0

    for i in range(len(string)):
        if not isdigit(string._buffer[i]):
            break
        end += 1 

    if not end:
        return 0
    
    return atol(string[:end])
