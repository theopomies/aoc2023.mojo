from math import max

from helpers.io import read_file
from helpers.vector import reduce_vector, map_vector


@value
struct GameInfo(CollectionElement):
    var red: Int
    var green: Int
    var blue: Int

    @staticmethod
    fn from_game_line(game_line: String) raises -> Self:
        var game_info = Self(red=0, green=0, blue=0)
        let reveals = game_line.split(": ")[1].split("; ")
        for i in range(len(reveals)):
            let reveal = reveals[i]
            let clues = reveal.split(", ")
            for j in range(len(clues)):
                let clue = clues[j].split(" ")
                let number = atol(clue[0])
                let color = clue[1]

                if color == "red":
                    game_info.red = max(number, game_info.red)
                if color == "green":
                    game_info.green = max(number, game_info.green)
                if color == "blue":
                    game_info.blue = max(number, game_info.blue)
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
    let game_lines = read_file(file_name).split("\n")
    let game_infos = map_vector[String, GameInfo](game_lines, GameInfo.from_game_line)

    print(part1(game_infos, red, green, blue))
    print(part2(game_infos))


fn part1(
    game_infos: DynamicVector[GameInfo],
    red: Int,
    green: Int,
    blue: Int,
) -> Int:
    let total_balls = red + green + blue
    var total = 0

    for i in range(len(game_infos)):
        let game = game_infos[i]
        let min_balls = game.red + game.green + game.blue

        if (
            total_balls >= min_balls
            and game.red <= red
            and game.green <= green
            and game.blue <= blue
        ):
            total += i + 1

    return total


fn part2(game_infos: DynamicVector[GameInfo]) -> Int:
    var total = 0

    for i in range(len(game_infos)):
        let game_info = game_infos[i]
        total += game_info.red * game_info.green * game_info.blue

    return total
