require "stringio"
s = +"abc"
StringIO.new(s).string << "!"
p s
