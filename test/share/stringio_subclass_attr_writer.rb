# Flag-only. A subclass of StringIO whose attribute writer or accessor is
# named `string` has the program's `string=`, not the class's: the String it
# is handed is the program's to keep (here in an ivar), and the class's own
# String is left as it was.
require "stringio"

# an attribute writer or accessor of the program's is the program's, not the
# class's
class Peeking < StringIO
  attr_writer :string
  def peek = @string
end
pk = Peeking.new(+"orig")
s = +"x"
pk.string = s
s << "!"
p pk.peek, pk.read

class Accessing < StringIO
  attr_accessor :string
end
ac = Accessing.new(+"orig")
s = +"x"
r = (ac.string = s)
r << "!"
p s, ac.string, r.equal?(s), ac.read

