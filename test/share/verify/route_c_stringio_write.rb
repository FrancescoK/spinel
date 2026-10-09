s = +"abc"
t = s
require "stringio"; io = StringIO.new(s); io.write("Z")
p s
p t
