struct S(Movable, Copyable):
    var value: Int

    fn __init__(inout self):
        print("Init")
        self.value = 42

    fn __moveinit__(inout self, owned other: Self):
        print("Moving")
        self.value = other.value

    fn __copyinit__(inout self, other: Self):
        print("Copying")
        # other.value = 42 # Other is not mutable so this fails
        self.value = 42

    fn consuming_method(owned self):
        print("Consuming")

    fn borrowing_method(self):
        print("Borrowing")

    fn inout_method(inout self):
        print("Inout")


fn main():
    let s = S()             # prints Init
    s.borrowing_method()    # prints Borrowing
    # s.inout_method()      # Should error because s in not mutable
    s.consuming_method()    # prints Copy and Consuming: Because I do not give it ownership it musts create a copy before take ownership of the caller(copy)
    s^.consuming_method()   # only prints Consuming (yay)
    # let ss = s            # Should error because s is not initialized anymore
    # s.borrowing_method()  # Should error because s is not initialized anymore
    # Lets try to reuse s as a variable name
    # s = S()               # Errors because s is immutable (maybe uninitialized is the wrong term for them)
    var ss = S()            # prints Init
    ss.inout_method()       # prints Inout
    let sss = ss            # prints Copying, so ss should still be usable
    ss.borrowing_method()   # prints Borrowing, so it is still usable
    let ssss = ss^          # prints Moving
    # ss.borrowing_method() # Should error because ss is not initialized anymore