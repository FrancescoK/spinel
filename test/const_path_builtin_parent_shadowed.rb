# A builtin's own constant (the binary Encoding, Float::MAX, File::SEPARATOR)
# read inside a namespace whose module defines an unrelated constant of the
# same leaf name is the builtin's, not the program's.
module M
  module Flags
    BINARY = 4
    ASCII_8BIT = 6
    UTF_8 = 5
    MAX = 7
    PI = 8
    SEPARATOR = 9
  end

  def self.check(s)
    p s.encoding == Encoding::BINARY
    p s.encoding == ::Encoding::ASCII_8BIT
    p "x".encoding == Encoding::UTF_8
    p s.encoding == Encoding.find("ASCII-8BIT")
    p Float::MAX > 1e300
    p Math::PI.round(2)
    p File::SEPARATOR
    p Flags::BINARY
    p M::Flags::MAX
  end
end
M.check("a".b)

# a constant the program adds to a builtin it opens is still found
class Float
  MINE = 3
end
p Float::MINE

# a top-level constant is Object's, and only Object's
TOP = 1
p Object::TOP
begin
  p Kernel::TOP
rescue NameError => e
  p e.class
end
