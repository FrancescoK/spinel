# `return a, b` inside begin/ensure of a method that also answers a String
# defers the boxed Array through the ensure frame's slot.
def e(o)
  begin
    return 1, o if o.is_a?(Integer)
    "s"
  ensure
    $x = 1
  end
end
p e(3), e("q")
def blk(o)
  [1].each { return o, 9 if o }
  "n"
end
p blk(5), blk(nil)
def spl(o)
  return *o, 7 if o.is_a?(Array)
  o.to_s
end
p spl([1, 2]), spl(3)
def m3(o)
  return o, o if o
  [1, 2]
end
p m3(4), m3(nil)
