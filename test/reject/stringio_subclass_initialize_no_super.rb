# A subclass of StringIO whose initialize never calls super would be an
# empty StringIO here, where CRuby raises IOError (uninitialized stream) on
# its first use: refused (#9269)
require "stringio"

class NoSuper < StringIO
  def initialize(tag)
    @tag = tag
  end
end

n = NoSuper.new(1)
n.write "x"
p n.string
