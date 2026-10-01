# activesupport's Object#with yields, and its own public_send can reach
# itself, so it is lowered to take the block as a trailing parameter. A
# call reaching it as the Object fallback of a dispatch -- for a receiver
# whose class is not one of the program's, or a boxed one -- left that
# parameter out, and the C did not compile.
class Object
  def with(**attributes)
    old = {}
    begin
      attributes.each do |key, value|
        old[key] = public_send(key)
        public_send("#{key}=", value)
      end
      yield self
    ensure
      old.each { |key, v| public_send("#{key}=", v) }
    end
  end
end

class Box
  attr_accessor :v
  def initialize = @v = 1
end

b = Box.new
p(b.with(v: 5) { |o| o.v })
p b.v
def go(o, m) = o.public_send(m)
x = [b, "s"][ARGV.size]
p go(x, [:v, :with][ARGV.size])
p("str".with { |s| s.upcase })
