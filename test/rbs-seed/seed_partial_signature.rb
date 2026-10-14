# spinel: rbs-seed-check
# An optional positional (`?Integer`), a rest parameter in the middle of
# the list and a `self` return each dropped the whole --rbs signature of
# their method, so every parameter of it was left to the call sites, and
# one no call site binds (`far`, an entry point) widened to untyped. Each
# parameter now takes its own field of the seed, the rest parameter an
# empty one, and a `self` return names the class; the rest parameter is
# the one slot that still widens, by construction.
#
# `self` returned from a singleton method is the class object, not an
# instance (`fresh` builds). A keyword field carries its name and seeds
# the parameter of that name, whatever order the def or the signature
# lists the keywords in: `tag(pre: "", n:)` declared `(?pre: String, n:
# Integer)` and `rev(b:, a: 1)` declared `(?a: Integer, b: String)` both
# seed a String and an Integer where they belong (walked required-first
# the first pair swapped, walked in source order the second).
class Plotter
  def initialize
    @marks = 0
  end

  attr_reader :marks

  def self.fresh
    self
  end

  def put(x, y, color = 1)
    x * 10 + y + color
  end

  def tail(x, *xs, s)
    "#{s}#{x}#{xs.size}"
  end

  def mark(x)
    @marks += x
    self
  end

  def tag(pre: "", n:)
    "#{pre}#{n + 1}"
  end

  def rev(b:, a: 1)
    "#{b.upcase}#{a * 2}"
  end

  def far(a, b = 0)
    a - b
  end
end

pl = Plotter.fresh.new
puts pl.put(1, 2)
puts pl.put(1, 2, 5)
puts pl.tail(7, 8, 9, "t")
puts pl.mark(2).mark(3).marks
puts pl.tag(n: 4)
puts pl.tag(pre: "p", n: 9)
puts pl.rev(b: "r")
puts pl.rev(a: 3, b: "s")
