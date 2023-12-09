fn day9(args: VariadicList[StringRef]) raises:
    let input_file_lines = Path(args[1]).read_text().split("\n")
    var sensors = DynamicVector[Sensor](capacity=len(input_file_lines))

    for i in range(len(input_file_lines)):
        sensors.push_back(Sensor(input_file_lines[i]))

    print("Part1:", part1(sensors))
    print("Part2:", part2(sensors))


fn part1(sensors: DynamicVector[Sensor]) -> Int:
    var total = 0
    for i in range(len(sensors)):
        total += sensors[i].predict_next()
    return total


fn part2(sensors: DynamicVector[Sensor]) -> Int:
    var total = 0
    for i in range(len(sensors)):
        total += sensors[i].predict_previous()
    return total


@value
struct Sensor(CollectionElement):
    var history: DynamicVector[Int]

    fn __init__(inout self, line: String) raises:
        let values = line.split(" ")
        self.history = DynamicVector[Int](capacity=len(values))

        for i in range(len(values)):
            self.history.push_back(atol(values[i]))

    fn predict_next(self) -> Int:
        return Self._predict_next(self.history)

    @staticmethod
    fn _predict_next(history: DynamicVector[Int]) -> Int:
        var all_zeros = True

        for i in range(len(history)):
            all_zeros = all_zeros and history[i] == 0
            if not all_zeros:
                break

        if all_zeros:
            return 0

        var diffs = DynamicVector[Int](capacity=len(history) - 1)

        for i in range(len(history) - 1):
            diffs.push_back(history[i + 1] - history[i])

        return history[len(history) - 1] + Self._predict_next(diffs)

    fn predict_previous(self) -> Int:
        return Self._predict_previous(self.history)

    @staticmethod
    fn _predict_previous(history: DynamicVector[Int]) -> Int:
        var all_zeros = True

        for i in range(len(history)):
            all_zeros = all_zeros and history[i] == 0
            if not all_zeros:
                break

        if all_zeros:
            return 0

        var diffs = DynamicVector[Int](capacity=len(history) - 1)

        for i in range(len(history) - 1):
            diffs.push_back(history[i + 1] - history[i])

        return history[0] - Self._predict_previous(diffs)
