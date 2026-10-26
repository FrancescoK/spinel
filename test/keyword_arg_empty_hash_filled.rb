# An empty {} passed as a keyword argument is the hash the method fills, as
# a positional one is: with a nil default, required, or with a {} default;
# and passed through a ** rest on to the keyword that fills it.
class Lib
  def fill(into: nil)
    into[:xxx] = true if into
    into
  end

  def need(into:)
    into[:count] = 3
  end

  def fallback(into: {})
    into["k"] = :v
    into
  end

  def outer(**opts)
    inner(**opts)
  end

  def inner(into: nil, tag: "t")
    into[tag.to_sym] = 1 if into
  end
end

a = {}
Lib.new.fill(into: a)
p a
b = {}
Lib.new.need(into: b)
p b
c = {}
Lib.new.fallback(into: c)
p c
p Lib.new.fallback
d = {}
Lib.new.outer(into: d, tag: "seen")
p d
e = {}
Lib.new.outer(into: e)
p e
