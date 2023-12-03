fn filter_vector[
    T: AnyType
](vector: DynamicVector[T], predicate: fn (elem: T) capturing -> Bool) -> DynamicVector[
    T
]:
    var filtered_vector = DynamicVector[T](capacity=len(vector))

    for i in range(len(vector)):
        let elem = vector[i]
        if predicate(elem):
            filtered_vector.push_back(elem)

    return filtered_vector


fn map_vector[
    T: AnyType, O: AnyType
](vector: DynamicVector[T], mapping_fn: fn (elem: T) capturing -> O) -> DynamicVector[
    O
]:
    var mapped_vector = DynamicVector[O](capacity=len(vector))

    for i in range(len(vector)):
        let elem = mapping_fn(vector[i])
        mapped_vector.push_back(elem)

    return mapped_vector


fn map_vector[
    T: AnyType, O: AnyType
](
    vector: DynamicVector[T], mapping_fn: fn (elem: T) raises capturing -> O
) raises -> DynamicVector[O]:
    var mapped_vector = DynamicVector[O](capacity=len(vector))

    for i in range(len(vector)):
        let elem = mapping_fn(vector[i])
        mapped_vector.push_back(elem)

    return mapped_vector


fn reduce_vector[
    T: AnyType, O: AnyType
](vector: DynamicVector[T], initial_value: O, reducer: fn (elem: T, acc: O) -> O,) -> O:
    var acc = initial_value

    for i in range(len(vector)):
        let elem = vector[i]
        acc = reducer(elem, acc)

    return acc


fn reduce_vector[
    T: AnyType, O: AnyType
](
    vector: DynamicVector[T],
    initial_value: O,
    reducer: fn (elem: T, acc: O) capturing -> O,
) -> O:
    var acc = initial_value

    for i in range(len(vector)):
        let elem = vector[i]
        acc = reducer(elem, acc)

    return acc


fn reduce_vector[
    T: AnyType, O: AnyType
](
    vector: DynamicVector[T],
    initial_value: O,
    reducer: fn (elem: T, acc: O, index: Int) capturing -> O,
) -> O:
    var acc = initial_value

    for i in range(len(vector)):
        let elem = vector[i]
        acc = reducer(elem, acc, i)

    return acc


fn sum(lhs: Int, rhs: Int) -> Int:
    return lhs + rhs


fn for_each_vector[
    T: AnyType
](vector: DynamicVector[T], callback: fn (elem: T) capturing -> NoneType):
    for i in range(len(vector)):
        let elem = vector[i]
        callback(elem)


fn for_each_vector[
    T: AnyType
](vector: DynamicVector[T], callback: fn (elem: T) raises capturing -> NoneType) raises:
    for i in range(len(vector)):
        let elem = vector[i]
        callback(elem)
