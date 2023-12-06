fn split(
    base: String, delimiter: String, recurring: Bool = False
) raises -> DynamicVector[String]:
    let splitted = base.split(delimiter)

    if not recurring:
        return splitted

    var filtered = DynamicVector[String](capacity=len(splitted))
    let current: String

    for i in range(len(splitted)):
        if current := splitted[i]:
            filtered.push_back(current ^)

    return filtered
