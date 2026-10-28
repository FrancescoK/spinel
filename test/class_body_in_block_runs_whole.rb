# A class body opened in an iterator's block or in a begin with a rescue
# clause runs its statements whole: its mixins, attrs, aliases, undefs and
# visibility words all apply.
module B; def b = :b; end
module E; def e = :e; end
[1].each do
  class Z
    include B
    extend E
    attr_reader :q
    alias_method :bb, :b
    def initialize; @q = 5; end
    private def hid = 1
  end
end
begin
  class Y
    include B
    attr_accessor :r
    undef_method :b
  end
rescue
end
z = Z.new
p z.b, Z.e, z.q, z.bb, z.respond_to?(:hid)
y = Y.new
y.r = 2
p y.r, y.respond_to?(:b)
