# `recv.index(*a)` / `rindex` where a's length is only known at run time:
# a String takes one or two arguments, an Array none or one (none being the
# Enumerator), and a count either refuses names the receiver's own range.
# The splat table held String's 1..2 for both, so an Array given three
# was told "expected 1..2".
def args(*x) = x
a = [3, 1, 4, 1]
s = "hello"
p a.index(*args(1))
p a.rindex(*args(1))
p s.index(*args("l"))
p s.index(*args("l", 3))
p s.rindex(*args("l", 2))
[[1, 2], [1, 2, 3]].each do |x|
  begin
    p a.index(*x)
  rescue ArgumentError => e
    p e.message
  end
  begin
    p a.rindex(*x)
  rescue ArgumentError => e
    p e.message
  end
end
[[], ["l", 1, 2]].each do |x|
  begin
    p s.index(*x)
  rescue ArgumentError => e
    p e.message
  end
  begin
    p s.rindex(*x)
  rescue ArgumentError => e
    p e.message
  end
end
# none on an Array: the Enumerator, as `a.index` gives it
p a.index(*args())
p a.rindex(*args()).to_a
