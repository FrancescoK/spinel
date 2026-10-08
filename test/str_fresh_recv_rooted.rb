# A String receiver that is a fresh copy -- the reader of an ivar that an
# alias mutated hands out a copy of the shared buffer, and so does a read of
# a local that shares one -- was held only by an unrooted temp while the
# argument allocated. The strings are long enough to push the string heap
# past its collection threshold under SPINEL_GC_STRESS, and of equal length,
# so the argument's copy lands where the freed receiver was and a wrong answer
# reads true. Run by gc-minor-test under stress.
# spinel: gc-minor
class Names
  attr_reader :first, :last
  def initialize; @first = "A" * 3000; @last = "B" * 3000; end
end
nm = Names.new
f = nm.first; f << "!"
g = nm.last;  g << "?"

# a nilable receiver's guard, with a reader, a fresh value and a shared
# local as the argument
p nm.first.include?(nm.last)
p nm.first.start_with?(nm.last)
p nm.first.end_with?(nm.last)
p nm.first.index(nm.last)
p nm.first.casecmp?(nm.last)
p nm.first.include?("B" * 3000)
b = nm.last
p nm.first.include?(b)

# == between two locals that share a buffer: both reads are copies
a = nm.first
p a == b
p a != b
p a == nm.first

# the same reads inside parentheses
p (a) == b
p a == (b)
p nm.first.include?((b))
