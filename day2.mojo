from math import max

from helpers.string import (
    read_file,
    split_lines_to_slices,
    split_to_slices,
    for_each_string_slice,
)
from helpers.vector import reduce_vector, map_vector


@register_passable("trivial")
struct GameInfo:
    var red: Int
    var green: Int
    var blue: Int

    @staticmethod
    fn from_game_line(game_line: String) raises -> Self:
        var game_info = Self {red: 0, green: 0, blue: 0}

        let game_info_slice = split_to_slices(game_line, ": ")[1]
        let game_info_line = game_line[game_info_slice]
        let reveals_slices = split_to_slices(game_info_line, "; ")

        @parameter
        fn handle_reveal(reveal: String) raises:
            let clues_slices = split_to_slices(reveal, ", ")

            @parameter
            fn handle_clue(clue: String) raises:
                let slices = split_to_slices(clue, " ")
                let number = atol(clue[slices[0]])
                let color = clue[slices[1]]

                if color == "red":
                    game_info.red = max(number, game_info.red)
                    return
                if color == "green":
                    game_info.green = max(number, game_info.green)
                    return
                if color == "blue":
                    game_info.blue = max(number, game_info.blue)
                    return
                raise Error("Invalid color")

            for_each_string_slice(reveal, clues_slices, handle_clue)

        for_each_string_slice(game_info_line, reveals_slices, handle_reveal)

        return game_info


fn day2(args: VariadicList[StringRef]) raises:
    if len(args) != 5:
        print(
            "Day 2 expects 4 cli args in this order: inputFile, red balls, green balls,"
            " blue balls"
        )
        print("Day 2 performs part1 and part2 at the same time")
        raise Error("Invalid args")

    let file_name = args[1]
    let red = atol(args[2])
    let green = atol(args[3])
    let blue = atol(args[4])
    let file = read_file(file_name)
    let game_slices = split_lines_to_slices(file)
    let game_infos = DynamicVector[GameInfo](capacity=len(game_slices))

    @parameter
    fn handle_game(game_line: String) raises:
        game_infos.push_back(GameInfo.from_game_line(game_line))

    for_each_string_slice(file, game_slices, handle_game)

    print(part1(game_infos, red, green, blue))
    print(part2(game_infos))


fn part1(
    game_infos: DynamicVector[GameInfo],
    red: Int,
    green: Int,
    blue: Int,
) -> Int:
    let total_balls = red + green + blue

    @parameter
    fn is_game_possible(game: GameInfo) -> Bool:
        let min_balls = game.red + game.green + game.blue

        return (
            total_balls >= min_balls
            and game.red <= red
            and game.green <= green
            and game.blue <= blue
        )

    let possible_games = map_vector[GameInfo, Bool](game_infos, is_game_possible)

    fn sum_possible_game_ids(game_is_possible: Bool, acc: Int, game_index: Int) -> Int:
        if not game_is_possible:
            return acc
        return acc + game_index + 1

    return reduce_vector(possible_games, 0, sum_possible_game_ids)


fn part2(game_infos: DynamicVector[GameInfo]) -> Int:
    fn sum_games_powers(game_info: GameInfo, acc: Int) -> Int:
        return acc + game_info.red * game_info.green * game_info.blue

    return reduce_vector(game_infos, 0, sum_games_powers)
