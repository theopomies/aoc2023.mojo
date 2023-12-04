from helpers.string import read_file, split_lines_to_slices, split_to_slices, Slices
from helpers.vector import map_vector, reduce_vector, filter_vector, sum


fn day4(args: VariadicList[StringRef]) raises:
    if len(args) != 2:
        print("Usage, ./main <filename>")
        raise Error("Invalid args")

    let file_input = read_file(args[1])
    let cards_slices = split_lines_to_slices(file_input)

    fn remove_card_number(card_slice: slice) -> slice:
        let substr_slice = split_to_slices(file_input[card_slice], ": ")[1]
        let start = substr_slice.start + card_slice.start
        let end = substr_slice.end + card_slice.start
        return slice(start, end)

    let card_infos = map_vector[slice, slice](cards_slices, remove_card_number)

    fn split_card_infos_reducer(
        card_infos: slice, owned split_cards_slices: DynamicVector[Tuple[slice, slice]]
    ) raises -> DynamicVector[Tuple[slice, slice]]:
        return split_cards_slices ^

    """ This must be done proceduraly with a for-loop since:
        - `map_vector` cannot resolve a viable candidate: https://github.com/modularml/mojo/issues/1366
        - `for_each`'s callback needs to capture the `DynamicVector[Tuple[slice, slice]]`
        and it errors for "mutating an rvalue of type `DynamicVector[Tuple[slice, slice]]`" (cryptic)
        - `reduce_vector` cannot resolve either and errors with:
        "candidate not viable: result cannot bind generic !mlirtype to memory-only type 'DynamicVector[Tuple[slice, slice]]'"
    """
    var card_infos_split = DynamicVector[Tuple[slice, slice]](capacity=len(card_infos))
    for i in range(len(card_infos)):
        let card_info = file_input[card_infos[i]]
        var slices = split_to_slices(card_info, " | ")

        if len(slices) != 2:
            raise Error("Invalid card line:" + card_info)

        slices[0].start += card_infos[i].start
        slices[1].start += card_infos[i].start
        slices[0].end += card_infos[i].start
        slices[1].end += card_infos[i].start

        card_infos_split.push_back(Tuple(slices[0], slices[1]))

    fn count_winning_numbers_in_card(card_infos: Tuple[slice, slice]) raises -> Int:
        let winning_numbers_line = file_input[card_infos.get[0, slice]()]
        let card_numbers_line = file_input[card_infos.get[1, slice]()]

        # Prevents the lines like "  1" with padding to break the algo
        fn is_not_empty_slice(s: slice) -> Bool:
            return s.end != s.start

        # Using this to try higher order functions that way
        fn slice_to_int(base: String) -> fn (s: slice) raises capturing -> Int:
            fn _slice_to_int(s: slice) raises -> Int:
                return atol(base[s])

            return _slice_to_int

        let winning_numbers = map_vector[slice, Int](
            filter_vector(
                split_to_slices(winning_numbers_line, " "), is_not_empty_slice
            ),
            slice_to_int(winning_numbers_line),
        )
        let card_numbers = map_vector[slice, Int](
            filter_vector(split_to_slices(card_numbers_line, " "), is_not_empty_slice),
            slice_to_int(card_numbers_line),
        )

        fn number_is_winning(number: Int) -> Bool:
            for i in range(len(winning_numbers)):
                if winning_numbers[i] == number:
                    return True
            return False

        return len(filter_vector(card_numbers, number_is_winning))

    let winning_numbers_in_each_card = map_vector[Tuple[slice, slice], Int](
        card_infos_split, count_winning_numbers_in_card
    )

    print("Part1:", part1(winning_numbers_in_each_card))
    print("Part2:", part2(winning_numbers_in_each_card))


fn part1(winning_numbers_in_each_card: DynamicVector[Int]) -> Int:
    fn sum_card_value(winning_numbers_in_card: Int, acc: Int) -> Int:
        if not winning_numbers_in_card:
            return acc
        return acc + 2 ** (winning_numbers_in_card - 1)

    return reduce_vector(winning_numbers_in_each_card, 0, sum_card_value)


fn part2(winning_numbers_in_each_card: DynamicVector[Int]) -> Int:
    var card_counts = DynamicVector[Int](capacity=len(winning_numbers_in_each_card))
    for i in range(len(winning_numbers_in_each_card)):
        card_counts.push_back(1)

    for i in range(len(winning_numbers_in_each_card)):
        let winning_numbers = winning_numbers_in_each_card[i]
        for c in range(winning_numbers):
            card_counts[i + c + 1] += card_counts[i]

    return reduce_vector(card_counts, 0, sum)
