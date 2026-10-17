# A subclass with no initialize of its own runs its parent's, and a `new`
# whose receiver is a constant path (N::Frag.new(self)) may reach that
# initialize too: the parameter keeps both argument classes, not only the
# MyDoc a local hands the subclass's constructor (#9435).
module N
  class Doc
    def frag = N::Frag.new(self)
  end
  class Frag
    def initialize(d)
      @d = d
    end
    def d = @d
  end
end
class MyDoc < N::Doc; end
class MyFrag < N::Frag; end
h = MyDoc.new
f = MyFrag.new(h)
p f.d.class
p N::Doc.new.frag.d.class
