from helpers.string import split


fn day6(args: VariadicList[StringRef]) raises:
    let input_file_lines = Path(args[1]).read_text().split("\n")
    let times = split(input_file_lines[0], " ", True)
    let distance_records = split(input_file_lines[1], " ", True)

    print("Part1:", part1(times, distance_records))
    print("Part2:", part2(times, distance_records))


@always_inline
fn get_distance(pressed_time: Int, max_time: Int) -> Int:
    return (max_time - pressed_time) * pressed_time


fn part1(
    times: DynamicVector[String], distance_records: DynamicVector[String]
) raises -> Int:
    var total = 0
    for i in range(1, len(times)):
        let max_time = atol(times[i])
        let distance_record = atol(distance_records[i])
        let possible_distances = get_races_possibilities(max_time, distance_record)
        if not total:
            total = 1
        if possible_distances:
            total *= possible_distances
    return total


fn part2(
    times: DynamicVector[String], distance_records: DynamicVector[String]
) raises -> Int:
    var max_time = times[1]
    var distance_record = distance_records[1]
    for i in range(2, len(times)):
        max_time += times[i]
        distance_record += distance_records[i]

    let distance_record_number = atol(distance_record)
    let max_time_number = atol(max_time)
    return get_races_possibilities(max_time_number, distance_record_number)


@always_inline
fn get_races_possibilities(max_time: Int, record_distance: Int) -> Int:
    var total = 0

    for pressed_time in range(max_time):
        let distance = get_distance(pressed_time, max_time)
        if distance > record_distance:
            total += 1

    return total
