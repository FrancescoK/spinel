# The literal block selects the yield tail of a block_given? branch.
# A native String reader in that block returns the object's handle.
require "stringio"
s = +"start"
r = StringIO.open(s) { |io| io << "!"; io.string }
r << "?"
p [s, r]
r = StringIO.open("fresh") { |io| io.read }
r << "+"
p [s, r]

# A call without a block still answers the IO, and a block may answer
# a non-String even when another call returns a borrowed String.
io = StringIO.open("reader")
p io.read
p StringIO.open("size") { |io| io.read.length }

def optional_value
  if block_given?
    yield
  else
    +"default"
  end
end
r = optional_value { s }
r << "b"
p s
p optional_value

def unless_value
  unless block_given?
    +"default"
  else
    yield
  end
end
r = unless_value { s }
r << "u"
p s
p unless_value
