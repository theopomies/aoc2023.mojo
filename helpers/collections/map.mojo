trait NaiveMapKeyable(CollectionElement, Stringable):
    pass


@value
struct StringKey(NaiveMapKeyable):
    var _string: String

    fn __init__(inout self, string: String):
        self._string = string

    fn __init__(inout self, string: StringLiteral):
        self._string = string

    fn __str__(self) -> String:
        return self._string


@value
struct NaiveMap[K: NaiveMapKeyable, V: CollectionElement](Sized, CollectionElement):
    """Doesn't support deletion."""

    var _keys: DynamicVector[K]
    var _values: DynamicVector[V]

    fn __init__(inout self):
        self._keys = DynamicVector[K]()
        self._values = DynamicVector[V]()

    fn __init__(inout self, capacity: Int):
        self._keys = DynamicVector[K](capacity)
        self._values = DynamicVector[V](capacity)

    fn __len__(self) -> Int:
        return len(self._keys)

    fn __setitem__(
        inout self,
        key: K,
        value: V,
    ):
        let key_str = str(key)
        for i in range(len(self._keys)):
            let candidate_key = str(self._keys[i])
            if candidate_key == key_str:
                self._values[i] = value
                return

        self._keys.append(key)
        self._values.append(value)

    fn __getitem__(
        self,
        key: K,
    ) raises -> V:
        let key_str = str(key)
        for i in range(len(self._keys)):
            let candidate_key = str(self._keys[i])
            if candidate_key == key_str:
                return self._values[i]

        raise Error('KeyError, key "' + key_str + '" not found.')

    fn keys(self) -> DynamicVector[String]:
        var keys = DynamicVector[String](len(self._keys))
        for i in range(len(self._keys)):
            keys.push_back(str(self._keys[i]))
        return keys


############### HashMap ###############
trait Hashable(Intable):
    pass


struct HashMap[K: Hashable, V: CollectionElement](Sized):
    var _size: Int

    fn __len__(self) -> Int:
        return self._size
