# A method handing its own block on to a String builtin (`&block`, `&`) is
# called with a block at one site and without at another: each site gets
# the builtin's own form -- the block form runs the caller's block, the
# blockless one answers what it answers (split's Array, an Enumerator).
class Held
  def initialize(s) = @str = s
  def split(*args, &block) = @str.split(*args, &block)
  def each_line(&block) = @str.each_line(&block)
  def each_char(&) = @str.each_char(&)
end

h = Held.new("a b\nc d\n")
p h.split
p h.split(" ")
r = h.split("\n") { |w| p w }
p r
pr = proc { |w| print w.strip, ";" }
p h.split(" ", &pr)
p h.each_line.to_a
h.each_line { |l| p l }
p h.each_char.first(3)
n = 0
h.each_char { n += 1 }
p n
