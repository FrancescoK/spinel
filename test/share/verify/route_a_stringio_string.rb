require "stringio"
s = +"abc"
r = StringIO.new(s).string
r << "!"
p s
p r
