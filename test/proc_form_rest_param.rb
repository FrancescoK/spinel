# A yielding method with a *rest, reached through a poly receiver, runs its
# proc-form clone, which takes the rest as the array the dispatch packs.
class A
  def item(label = "", *fmt, &blk)
    [label, fmt, blk.call]
  end
end
class B
  def item(label = "", *fmt)
    [:b, label, fmt, yield]
  end
end
objs = [A.new, B.new]
objs.each { |o| p o.item("x", 1, 2) { 3 } }
