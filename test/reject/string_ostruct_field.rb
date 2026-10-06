# An OpenStruct field reads back the String it was given, s itself. The
# read was a copy and s stayed "abc": refused, not compiled wrong.
require "ostruct"
s = +"abc"
r = OpenStruct.new(name: s).name
r << "!"
p s
p r
