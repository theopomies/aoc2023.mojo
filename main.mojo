from sys import argv

from day1 import day1
from day2 import day2
from day3 import day3

from python import Python


fn main() raises:
    let time = Python.import_module("time")
    let beg = time.monotonic()
    day3(argv())
    let end = time.monotonic()
    print((end - beg).to_string() + "s")
