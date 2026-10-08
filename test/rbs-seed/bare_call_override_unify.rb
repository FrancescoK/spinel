# A bare call to a method the enclosing class defines and a subclass
# overrides: the type is every override's return unified, as the dispatch
# codegen emits switches over them all. The #4593 rule answered the base's
# declared return alone, and `@snap = attributes` assigned the switch's
# sp_RbVal to a declared Hash slot (#4600, webit-wagner).
# spinel: rbs-seed-check
class Base
  def attributes
    {}
  end

  def snapshot
    @snap = attributes
    nil
  end
end

class Post < Base
  def attributes
    { "a" => "b" }
  end
end

x = Post.new
x.snapshot
p x.attributes
