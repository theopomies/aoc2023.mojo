from helpers.io import read_file
from helpers.vector import map_vector, filter_vector


fn is_not_empty_string(s: String) -> Bool:
    return s != ""


@value
struct Card(CollectionElement):
    var winning_numbers: Int

    @staticmethod
    fn from_full_card_line(card_line: String) raises -> Self:
        return Self.from_full_card_numbers(card_line.split(": ")[1])

    @staticmethod
    fn from_full_card_numbers(full_card_numbers: String) raises -> Self:
        let full_numbers = full_card_numbers.split(" | ")
        let winning_numbers_as_str = filter_vector[String](
            full_numbers[0].split(" "), is_not_empty_string
        )
        let card_numbers_as_str = filter_vector[String](
            full_numbers[1].split(" "), is_not_empty_string
        )
        var winning_numbers = DynamicVector[Int](capacity=len(winning_numbers_as_str))
        var card_numbers = DynamicVector[Int](capacity=len(card_numbers_as_str))

        for i in range(len(winning_numbers_as_str)):
            winning_numbers.push_back(atol(winning_numbers_as_str[i]))
        for i in range(len(card_numbers_as_str)):
            card_numbers.push_back(atol(card_numbers_as_str[i]))

        var count = 0

        for i in range(len(winning_numbers)):
            for j in range(len(card_numbers)):
                if winning_numbers[i] == card_numbers[j]:
                    count += 1
                    break

        return Self(count)


fn day4(args: VariadicList[StringRef]) raises:
    if len(args) != 2:
        print("Usage, ./main <filename>")
        raise Error("Invalid args")

    let cards_lines = read_file(args[1]).split("\n")
    let cards = map_vector[String, Card](cards_lines, Card.from_full_card_line)

    print("Part1:", part1(cards))
    print("Part2:", part2(cards))


fn part1(cards: DynamicVector[Card]) -> Int:
    var total = 0
    for i in range(len(cards)):
        let card = cards[i]
        if not card.winning_numbers:
            continue
        total += 2 ** (card.winning_numbers - 1)
    return total


fn part2(cards: DynamicVector[Card]) -> Int:
    var card_counts = DynamicVector[Int](capacity=len(cards))
    for i in range(len(cards)):
        card_counts.push_back(1)

    for i in range(len(cards)):
        let winning_numbers = cards[i].winning_numbers
        for c in range(winning_numbers):
            card_counts[i + c + 1] += card_counts[i]

    var total = 0
    for i in range(len(card_counts)):
        total += card_counts[i]

    return total
