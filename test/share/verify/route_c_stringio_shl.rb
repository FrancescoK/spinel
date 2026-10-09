s = +"abc"
t = s
require "stringio"; io = StringIO.new(s); io.seek(0, IO::SEEK_END); io << "!"
p s
p t
