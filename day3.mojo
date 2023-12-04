from helpers.io import read_file
from helpers.vector import filter_vector

# Note: This is very suboptimal, we traverse the vectors too much atm
fn day3(args: VariadicList[StringRef]) raises:
    let input_file_lines = read_file(args[1]).split("\n")
    var symbols = DynamicVector[Symbol]()
    var part_numbers = DynamicVector[PartNumber]()

    for y in range(len(input_file_lines)):
        let line = input_file_lines[y]
        let length = len(line)
        var x = 0
        let value: String

        while x < length:
            let candidate = line[x:]

            if value := scan_str_for_i(candidate):
                let offset = len(value)
                part_numbers.push_back(PartNumber(
                    pos=Position(
                        x,
                        x + offset - 1,
                        y
                    ),
                    value=atol(value)
                ))
                x += offset
                continue
            elif Symbol.is_symbol(candidate):
                symbols.push_back(Symbol(
                    pos= Position (
                        x_beg= x,
                        x_end= x,
                        y= y
                ),
                    is_gear_symbol= Symbol.check_gear_symbol(candidate),
                    adjacent_parts= 0,
                    gear_ratio= 0
                ))
            x += 1

    print("Part1:", part1(symbols, part_numbers))
    print("Part2:", part2(symbols, part_numbers))

fn part1(symbols: DynamicVector[Symbol], part_numbers: DynamicVector[PartNumber]) -> Int:
    var total = 0

    for i in range(len(part_numbers)):
        let pn = part_numbers[i]
        for j in range(len(symbols)):
            let symbol = symbols[j]
            if pn.is_adjacent(symbol.pos):
                total += pn.value
                break

    return total

fn part2(symbols: DynamicVector[Symbol], part_numbers: DynamicVector[PartNumber]) raises -> Int:
    fn is_gear_symbol(symbol: Symbol) -> Bool: return symbol.is_gear_symbol
    var gear_symbols = filter_vector(symbols, is_gear_symbol)
    var total = 0
    for i in range(len(gear_symbols)):
        var pn_count = 0
        var gear_ratio = 1
        for j in range(len(part_numbers)):
            let part_number = part_numbers[j]
            if part_number.is_adjacent(gear_symbols[i].pos):
                pn_count += 1
                gear_ratio *= part_number.value
        if pn_count == 2:
            total += gear_ratio
    return total

@value
struct Symbol(CollectionElement):
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


@value
struct Position(CollectionElement):
    var x_beg: Int
    var x_end: Int
    var y: Int


@value
struct PartNumber(CollectionElement):
    var value: Int
    var pos: Position

    fn is_adjacent(self, pos: Position) -> Bool:
        let is_close_verticaly = -1 <= self.pos.y - pos.y <= 1
        let is_close_horizontaly = 
            self.pos.x_beg - 1 <= pos.x_beg <= self.pos.x_end + 1
            or self.pos.x_beg - 1 <= pos.x_end <= self.pos.x_end + 1

        return is_close_verticaly and is_close_horizontaly

fn scan_str_for_i(string: String) -> String:
    var end = 0

    for i in range(len(string)):
        if not isdigit(string._buffer[i]):
            break
        end += 1 

    if not end:
        return ""
    
    return string[:end]
