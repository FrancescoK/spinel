# A Set named without a require splices set.rb ahead of the program;
# the lines after it keep their numbers.
p __LINE__
s = Set[1, 2]
p [s.size, __LINE__]
def where = __LINE__
p where
p [1, 2].to_set.include?(2), __LINE__
