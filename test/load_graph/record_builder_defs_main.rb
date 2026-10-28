# A class builder's block that no statement of the load phase places (here
# in a method body) is its class's body all the same: its includes, attrs,
# aliases, visibility and defs are the class's, as the registration
# applies them.
module M; def hi = "hi"; end
def mk
  Struct.new(:m) do
    include M
    attr_accessor :n
    alias_method :mm, :m
    private
    def s = m * 2
    public
    def t = s + 1
  end
end
K = mk
k = K.new(3)
k.n = 4
p [k.m, k.n, k.mm, k.t, k.hi]
begin; k.s; rescue NoMethodError => e; puts e.message; end
p(Struct.new(:q) do attr_reader :w; def u = q end.new(5).u)
