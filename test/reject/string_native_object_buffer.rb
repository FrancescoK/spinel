# StringIO.new(s) uses s itself as its buffer, so io.string is s. The C
# object keeps a copy and s stayed "abc": refused, not compiled wrong.
require "stringio"
s = +"abc"
StringIO.new(s).string << "!"
p s
