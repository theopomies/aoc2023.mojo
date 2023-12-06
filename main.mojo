from sys import argv

from day1 import day1
from day2 import day2
from day3 import day3
from day4 import day4
from day5 import day5
from day6 import day6 as day

from python import Python


fn main() raises:
    let time = Python.import_module("time")
    let beg = time.monotonic()
    day(argv())
    let end = time.monotonic()
    print(str(end - beg) + "s")
