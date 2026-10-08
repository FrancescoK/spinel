# A `**` operand that is a user object read out of a container (a boxed
# value) converts through its #to_hash, as CRuby converts any operand that
# is not a Hash: nil carries no keywords, an answer that is no Hash and an
# object without #to_hash raise TypeError. The boxed object reached the
# keyword binding unconverted and raised "no implicit conversion of H into
# Hash". Each conversion prints once, through a keyword merged beside the
# operand, the operand alone into named keywords and a **kwrest, a
# positional, a poly receiver, a block, a Struct, a Data, `new`, `super`, a
# class method, `send`, Method#call, a hash literal and a refused call.
# spinel: gc-minor
class H
  def to_hash = (puts "to_hash"; { z: 1 })
end
class N
  def to_hash = 5
end
class Q; end
S = Struct.new(:z, keyword_init: true)
D = Data.define(:z)
class A; def m(z: 0, **kw) = [:a, z, kw]; end
class B; def m(**kw) = [:b, kw]; end
class P
  def initialize(z: 0, **kw) = (@z = z; @kw = kw)
  def show = [@z, @kw]
end
class Base; def m(z: 0) = z; end
class Kid < Base; def m(**kw) = super(**kw); end
class C; def self.k(z:, **r) = [z, r]; end
def f(a: 0, **kw) = [a, kw]
def g(z:) = z
def h(**kw) = kw
def pos(*a) = a
def one(a) = a
def y = yield(**[H.new, 1][0])
def it(**kw) = yield(kw)

o = [H.new, 1, nil][0]
nl = [H.new, 1, nil][2]
p f(a: 2, **o)
p f(**o)
p g(**o)
p g(z: 5, **o)
p h(**o)
p h(**o, **o)
p pos(**o)
p f(**nl)
p [A.new, B.new].map { |r| r.m(**o) }
p y { |z:| z }
p proc { |**kw| kw }.call(**o)
p it(**o) { |kw| kw }
p S.new(**o)
p D.new(**o)
p P.new(**o).show
p Kid.new.m(**o)
p C.k(**o)
p send(:g, **o)
p method(:g).call(**o)
p({ **o, w: 2 })
begin
  one(1, 2, **o)
rescue ArgumentError => e
  p e.message
end
[[N.new, 1][0], [Q.new, 1][0], [1, "s"][0]].each do |bad|
  begin
    f(**bad)
  rescue TypeError => e
    p e.message
  end
  begin
    f(a: 1, **bad)
  rescue TypeError => e
    p e.message
  end
  begin
    p({ **bad })
  rescue TypeError => e
    p e.message
  end
end
