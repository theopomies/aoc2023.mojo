from math import max, min

from helpers.io import read_file


fn day5(args: VariadicList[StringRef]) raises:
    let input_lines = read_file(args[1]).split("\n")
    let seeds = get_seeds(input_lines)
    let seed_to_soil_map = Map.from_input_file(input_lines, "seed-to-soil map:")
    let soil_to_fertilizer_map = Map.from_input_file(
        input_lines, "soil-to-fertilizer map:"
    )
    let fertilizer_to_water_map = Map.from_input_file(
        input_lines, "fertilizer-to-water map:"
    )
    let water_to_light_map = Map.from_input_file(input_lines, "water-to-light map:")
    let light_to_temperature_map = Map.from_input_file(
        input_lines, "light-to-temperature map:"
    )
    let temperature_to_humidity_map = Map.from_input_file(
        input_lines, "temperature-to-humidity map:"
    )
    let humidity_to_location_map = Map.from_input_file(
        input_lines, "humidity-to-location map:"
    )

    print(
        "Part1:",
        part1(
            seeds,
            seed_to_soil_map,
            soil_to_fertilizer_map,
            fertilizer_to_water_map,
            water_to_light_map,
            light_to_temperature_map,
            temperature_to_humidity_map,
            humidity_to_location_map,
        ),
    )
    print(
        "Part2:",
        part2(
            seeds,
            seed_to_soil_map,
            soil_to_fertilizer_map,
            fertilizer_to_water_map,
            water_to_light_map,
            light_to_temperature_map,
            temperature_to_humidity_map,
            humidity_to_location_map,
        ),
    )


fn get_seeds(input_lines: DynamicVector[String]) raises -> DynamicVector[Int]:
    let seeds_numbers_as_str = input_lines[0].split(" ")
    var seeds_numbers = DynamicVector[Int](capacity=len(seeds_numbers_as_str))
    for i in range(1, len(seeds_numbers_as_str)):
        seeds_numbers.push_back(atol(seeds_numbers_as_str[i]))
    return seeds_numbers


alias Source = Int
alias Destination = Int


@value
struct Map:
    var ranges: DynamicVector[MapRange]

    @staticmethod
    fn from_input_file(
        input_lines: DynamicVector[String],
        start_delimiter: String,
    ) raises -> Self:
        var line_idx = 0
        let line: String
        var ranges: DynamicVector[MapRange] = DynamicVector[MapRange]()

        for i in range(len(input_lines)):
            if input_lines[i] == start_delimiter:
                line_idx = i + 1
                break

        for i in range(line_idx, len(input_lines)):
            if not (line := input_lines[line_idx]):
                break
            ranges.push_back(MapRange.from_range_line(line))
            line_idx += 1

        return Self(ranges)

    fn __getitem__(self, source: Source) -> Destination:
        for i in range(len(self.ranges)):
            let current_range = self.ranges[i]
            let mapped = current_range[source]
            if mapped != -1:
                return mapped
        return source

    fn __getitem__(self, source_range: Range) -> DynamicVector[Range]:
        var mapped_destinations = DynamicVector[Range]()
        var sources_remaining_to_map = DynamicVector[Range]()
        sources_remaining_to_map.push_back(source_range)

        for i in range(len(self.ranges)):
            let range_map = self.ranges[i]
            var sources_not_mapped = DynamicVector[Range]()
            for j in range(len(sources_remaining_to_map)):
                let source_range = sources_remaining_to_map[j]
                var mapped_range_result = range_map[source_range]
                if len(mapped_range_result.mapped_destination):
                    mapped_destinations.push_back(
                        mapped_range_result.mapped_destination[0]
                    )
                for k in range(len(mapped_range_result.sources_not_mapped)):
                    sources_not_mapped.push_back(
                        mapped_range_result.sources_not_mapped.pop_back()
                    )
            sources_remaining_to_map = sources_not_mapped ^

        for i in range(len(sources_remaining_to_map)):
            mapped_destinations.push_back(sources_remaining_to_map.pop_back())

        return mapped_destinations

    fn __getitem__(self, source_ranges: DynamicVector[Range]) -> DynamicVector[Range]:
        var destination_ranges = DynamicVector[Range]()

        for i in range(len(source_ranges)):
            var mapped_ranges = self[source_ranges[i]]
            for i in range(len(mapped_ranges)):
                destination_ranges.push_back(mapped_ranges.pop_back())

        return destination_ranges


@value
struct Range(CollectionElement, Stringable):
    var start: Source
    var end: Source

    fn is_valid(self) -> Bool:
        return self.start < self.end and self.start >= 0 and self.end >= 0

    fn __str__(self) -> String:
        return "[" + String(self.start) + ", " + String(self.end) + "]"


@value
struct MappedRangeResult(CollectionElement):
    var mapped_destination: DynamicVector[Range]
    var sources_not_mapped: DynamicVector[Range]


@value
struct MapRange(CollectionElement):
    var source_start: Int
    var source_end: Int
    var destination_start: Int

    fn __getitem__(self, source: Source) -> Destination:
        if source < self.source_start or source >= self.source_end:
            return -1
        return self.destination_start + source - self.source_start

    fn __getitem__(self, source: Range) -> MappedRangeResult:
        var mapped_range_result = MappedRangeResult(
            DynamicVector[Range](1), DynamicVector[Range](2)
        )

        if not source.is_valid():
            return mapped_range_result

        let beg = max(self.source_start, source.start)
        let end = min(self.source_end, source.end)

        let candidate = Range(self[beg], self[end - 1])
        if candidate.is_valid():
            mapped_range_result.mapped_destination.push_back(candidate ^)

        if source.start < self.source_start:
            let end = min(self.source_start, source.end)
            let candidate = Range(source.start, end)
            if candidate.is_valid():
                mapped_range_result.sources_not_mapped.push_back(candidate ^)

        if self.source_end < source.end:
            let start = max(self.source_end, source.start)
            let candidate = Range(start, source.end)
            if candidate.is_valid():
                mapped_range_result.sources_not_mapped.push_back(candidate ^)

        return mapped_range_result

    @staticmethod
    fn from_range_line(range_line: String) raises -> Self:
        let numbers = range_line.split(" ")
        let destination_start = atol(numbers[0])
        let source_start = atol(numbers[1])
        let length = atol(numbers[2])
        return Self(source_start, source_start + length, destination_start)


fn part1(
    seeds: DynamicVector[Int],
    seed_to_soil_map: Map,
    soil_to_fertilizer_map: Map,
    fertilizer_to_water_map: Map,
    water_to_light_map: Map,
    light_to_temperature_map: Map,
    temperature_to_humidity_map: Map,
    humidity_to_location_map: Map,
) -> Int:
    var min_location: Int = -1
    for i in range(len(seeds)):
        let seed = seeds[i]
        let soil = seed_to_soil_map[seed]
        let fertilizer = soil_to_fertilizer_map[soil]
        let water = fertilizer_to_water_map[fertilizer]
        let light = water_to_light_map[water]
        let temperature = light_to_temperature_map[light]
        let humidity = temperature_to_humidity_map[temperature]
        let location = humidity_to_location_map[humidity]
        if min_location == -1:
            min_location = location
        else:
            min_location = min(min_location, location)
    return min_location


fn part2(
    seeds: DynamicVector[Int],
    seed_to_soil_map: Map,
    soil_to_fertilizer_map: Map,
    fertilizer_to_water_map: Map,
    water_to_light_map: Map,
    light_to_temperature_map: Map,
    temperature_to_humidity_map: Map,
    humidity_to_location_map: Map,
) -> Int:
    var seed_ranges = DynamicVector[Range](capacity=len(seeds) // 2)

    for i in range(len(seeds) // 2):
        let start = seeds[2 * i]
        let length = seeds[2 * i + 1]
        seed_ranges.push_back(Range(start, start + length))

    let soils = seed_to_soil_map[seed_ranges]
    let fertilizers = soil_to_fertilizer_map[soils]
    let waters = fertilizer_to_water_map[fertilizers]
    let lights = water_to_light_map[waters]
    let temperatures = light_to_temperature_map[lights]
    let humidities = temperature_to_humidity_map[temperatures]
    let locations = humidity_to_location_map[humidities]
    var min_location_start = -1
    for i in range(len(locations)):
        let location_range = locations[i]
        if min_location_start == -1:
            min_location_start = location_range.start
        else:
            min_location_start = min(min_location_start, location_range.start)
    return min_location_start
