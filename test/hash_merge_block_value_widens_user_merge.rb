# A program whose own class defines `merge` still runs Hash#merge's
# conflict block when the block's value, or the merged argument, does not
# fit the receiver's variant.

class Doc
  def merge(other) = "doc+#{other}"
end
p Doc.new.merge(1)

m = {"a" => 1}
p m.merge("a" => 2) { |_k, o, n| "s#{o + n}" }
p m

q = {"a" => 1}
p q.merge({"b" => "x"}) { |_k, o, n| n }
p q.merge({"a" => "x"}) { |_k, o, n| [o, n] }
