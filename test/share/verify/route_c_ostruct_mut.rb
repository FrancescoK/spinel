s = +"abc"
t = s
require "ostruct"; OpenStruct.new(n: s).n << "!"
p s
p t
