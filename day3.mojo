from helpers.string import read_file, split_lines_to_slices, Slices, for_each_string_slice
from helpers.vector import for_each_vector, filter_vector, reduce_vector, map_vector

# Note: This is very suboptimal, we traverse the vectors too much atm

fn day3(args: VariadicList[StringRef]) raises:
    let input_file = read_file(args[1])
    let input_lines_slices = split_lines_to_slices(input_file)
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
                    },
                    is_gear_symbol: Symbol.check_gear_symbol(candidate),
                    adjacent_parts: 0,
                    gear_ratio: 0
                })
            x += 1

    for_each_string_slice(input_file, input_lines_slices, handle_line)

    print("Part1:", part1(symbols, part_numbers))
    print("Part2:", part2(symbols, part_numbers))

fn part1(symbols: DynamicVector[Symbol], part_numbers: DynamicVector[PartNumber]) raises -> Int:
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

fn part2(symbols: DynamicVector[Symbol], part_numbers: DynamicVector[PartNumber]) raises -> Int:
    fn is_gear_symbol(symbol: Symbol) -> Bool: return symbol.is_gear_symbol
    let gear_symbols = filter_vector(symbols, is_gear_symbol)

    fn count_and_multiply_adjacent_parts(symbol: Symbol) -> Symbol:
        @parameter
        fn is_adjacent_symbol(pn: PartNumber) -> Bool:
            return pn.is_adjacent(symbol.pos)

        let adjacent_parts = filter_vector(part_numbers, is_adjacent_symbol)
        var updated_symbol = symbol
        updated_symbol.adjacent_parts = len(adjacent_parts)
        
        fn mul_values(part_number: PartNumber, acc: Int) -> Int:
            return acc * part_number.value

        updated_symbol.gear_ratio = reduce_vector(adjacent_parts, 1, mul_values)

        return updated_symbol^

    let updated_gear_symbols = map_vector[Symbol, Symbol](gear_symbols, count_and_multiply_adjacent_parts)

    fn symbol_is_gear(symbol: Symbol) -> Bool:
        return symbol.adjacent_parts == 2
    let valid_gears = filter_vector(updated_gear_symbols, symbol_is_gear)
    
    fn sum_gear_ratios(symbol: Symbol, acc: Int) -> Int:
        return acc + symbol.gear_ratio

    return reduce_vector(valid_gears, 0, sum_gear_ratios)

@register_passable("trivial")
struct Symbol:
    var pos: Position
    var is_gear_symbol: Bool
    var adjacent_parts: Int
    var gear_ratio: Int

    @staticmethod
    fn is_symbol(candidate: String) -> Bool:
        let candidate_char = candidate[0] 

        return not isdigit(candidate_char._buffer[0]) and candidate_char != "."

    @staticmethod
    fn check_gear_symbol(candidate: String) -> Bool:
        let candidate_char = candidate[0] 

        return candidate_char == "*"


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
        let is_close_verticaly = -1 <= self.pos.y - pos.y <= 1
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
