require "ostruct"
s = +"abc"
r = OpenStruct.new(name: s).name
r << "!"
p s
p r
