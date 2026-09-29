# `extend M` runs M.extended(base) the same way: `base.name` reads the
# extender, other `base.m(...)` calls are class-body calls on it.
module Tagged
  def self.extended(base)
    base.extend Comparable
    base.tag_name "t-#{base.name.downcase}"
  end
  def tag_name(n = nil)
    return @tag if n.nil?
    @tag = n
  end
end
class Foo
  extend Tagged
end
module Bar
  extend Tagged
end
p Foo.tag_name, Bar.tag_name
