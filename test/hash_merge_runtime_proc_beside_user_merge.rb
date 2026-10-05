# Hash#merge on a typed Hash given its conflict block as a proc at run time
# (`&proc { }`, `&pr`), in a program whose own class defines merge: the
# proc decides the value. The typed arm read no block body and stored nil.
class Doc
  def merge(other) = "doc+#{other}"
end
p Doc.new.merge(1)
m = {"a" => 1}
p m.merge("a" => 2, &proc { |_k, o, n| "s#{o + n}" })
pr = proc { |_k, o, n| o + n }
p m.merge("a" => 5, "b" => 7, &pr)
p m
