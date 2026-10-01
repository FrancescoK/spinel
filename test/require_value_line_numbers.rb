p require("set")
p __LINE__
x = require "json"
p [x, __LINE__]
p [3, 1, 2].partition { |v| v > 1 }
p __LINE__
def where = __LINE__
p where
p 7.clamp(1, 5)
p __LINE__
