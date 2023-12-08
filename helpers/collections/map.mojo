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


############### BTreeMap ###############
# alias Map = BTreeMap


# trait Keyable(CollectionElement, Intable):  # , Hashable):
#     pass


# struct BTreeMap[K: Keyable, V: CollectionElement](Sized):
#     """A B-Tree implementation of a map.
#     Note:
#         TODO: This implementation is not balanced.
#         TODO: This implementation is not thread-safe.
#         TODO: This implementation does not support deletion.
#         TODO: This implementation does not support iteration.
#         TODO: This implementation does not support hashing.
#         TODO: This implementation does not support equality.
#     """

#     var _size: Int
#     var _root: AnyPointer[MapNode[V]]

#     fn __len__(self) -> Int:
#         return self._size

#     fn _insert(
#         inout self,
#         key: K,
#         value: V,
#     ):
#         if not self._root:
#             let node = MapNode[V](int(key), value)
#             self._size += 1
#             self._root = AnyPointer[MapNode[V]].alloc(1)
#             self._root.emplace_value(node)
#             return

#         let node_ptr = self._get(int(key))
#         if node_ptr:
#             var node = node_ptr.take_value()
#             node._value = value
#             node_ptr.emplace_value(node)
#             return

#         let node = MapNode[V](int(key), value)
#         var prev_ptr = self._root
#         var current_ptr = self._root
#         var current = current_ptr.take_value()

#         while True:
#             if node._key < current._key:
#                 if current._left:
#                     current_ptr = current._left
#                     prev_ptr.emplace_value(current)
#                     current = current_ptr.load(0)
#                 else:
#                     current._left = Pointer[MapNode[V]].alloc(1)
#                     current._left.store(node)
#                     break
#             else:
#                 if current._right:
#                     current_ptr = current._right
#                     current = current_ptr.load(0)
#                 else:
#                     current._right = Pointer[MapNode[V]].alloc(1)
#                     current._right.store(node)
#                     break

#     fn __setitem__(
#         inout self,
#         key: K,
#         value: V,
#     ):
#         self._insert(key, value)

#     fn _get(
#         self,
#         key: Int,
#     ) -> AnyPointer[MapNode[V]]:
#         if not self._root:
#             return AnyPointer[MapNode[V]]()

#         var current_ptr = self._root
#         var current = current_ptr.take_value()

#         # while True:
#         #     if key == current._key:
#         #         return current_ptr
#         #     elif key < current._key:
#         #         if current._left:
#         #             current_ptr = current._left
#         #             current = current_ptr.load(0)
#         #         else:
#         #             return Pointer[MapNode[V]].get_null()
#         #     else:
#         #         if current._right:
#         #             current_ptr = current._right
#         #             current = current_ptr.load(0)
#         #         else:
#         #             return Pointer[MapNode[V]].get_null()
#         return AnyPointer[MapNode[V]]()

#     # fn __getitem__(
#     #     self,
#     #     key: K,
#     # ) raises -> V:
#     #     let node = self._get(int(key)).load(0)._value


# struct MapNode[V: CollectionElement](CollectionElement):
#     var _key: Int
#     var _value: V
#     var _left: AnyPointer[Self]
#     var _right: AnyPointer[Self]

#     fn __init__(inout self, key: Int, value: V):
#         self._key = key
#         self._value = value
#         self._left = AnyPointer[Self]()
#         self._right = AnyPointer[Self]()

#     fn __copyinit__(inout self, other: Self):
#         self._key = other._key
#         self._value = other._value
#         if other._left:
#             self._left = AnyPointer[Self].alloc(1)
#             self._left.emplace_value(other._left.take_value())
#         else:
#             self._left = Pointer[Self]()

#         if other._right:
#             self._right = AnyPointer[Self].alloc(1)
#             self._right.emplace_value(other._right.take_value())
#         else:
#             self._right = Pointer[Self]()

#     fn __moveinit__(inout self: Self, owned other: Self):
#         self._key = other._key
#         self._value = other._value
#         self._left = other._left ^
#         self._right = other._right ^


# trait Comparable:
#     fn __eq__(self, other: Self) -> Bool:
#         pass

#     fn __ne__(self, other: Self) -> Bool:
#         pass

#     fn __lt__(self, other: Self) -> Bool:
#         pass

#     fn __le__(self, other: Self) -> Bool:
#         pass

#     fn __gt__(self, other: Self) -> Bool:
#         pass

#     fn __ge__(self, other: Self) -> Bool:
#         pass


# trait Hashable:
#     fn __hash__(self) -> Hash:
#         pass


# struct Hash(Comparable):
#     var _value: Int

#     fn __init__(inout self, value: Int):
#         self._value = value

#     fn __eq__(self, other: Hash) -> Bool:
#         return self._value == other._value

#     fn __ne__(self, other: Hash) -> Bool:
#         return self._value != other._value

#     fn __lt__(self, other: Hash) -> Bool:
#         return self._value < other._value

#     fn __le__(self, other: Hash) -> Bool:
#         return self._value <= other._value

#     fn __gt__(self, other: Hash) -> Bool:
#         return self._value > other._value

#     fn __ge__(self, other: Hash) -> Bool:
#         return self._value >= other._value
