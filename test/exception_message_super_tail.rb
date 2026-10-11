# An exception subclass's #message or #to_s that answers `super` alone
# answers the exception's message, as Exception#message does: the text it
# was given, else the class name. Untyped, the override answered nil.
class B < StandardError
  def message = super
end
class C < B; end
class D < StandardError
  def to_s = super
end
class E < StandardError
  def message
    super
  end
end
p B.new(+"b").message, C.new("c").message, D.new("d").to_s, E.new("e").message
p B.new.message, C.new.message, D.new.to_s, E.new(nil).message
begin
  raise C, "raised"
rescue B => e
  p e.message
end
p [B.new("x"), D.new("y"), StandardError.new("z")].map(&:message)
p "#{B.new("i")}|#{E.new("j").message}"

# beside a builtin reopening that defines #message, a subclass of another
# builtin still reaches Exception's
class RuntimeError
  def message = "RT:" + super
end
class R < RuntimeError
  def message = super
end
class G < StandardError
  def message = super
end
p R.new("r").message, G.new("g").message, RuntimeError.new("rt").message

# an override with an optional or rest parameter, read with no arguments
class OA < StandardError; def message(x = 1) = super(); end
class OR < StandardError; def message(*) = super; end
class OD < StandardError; def message(x = 1) = "own#{x}"; end
p OA.new("oa").message, OR.new("or").message, OD.new("od").message
p [OA.new("a"), OR.new("b"), OD.new].map(&:message)
begin; raise OD; rescue => e; p e.message; end

# Exception#message answers #to_s: a #to_s of the class, or of a class
# below it, answers through `super`
class T1 < StandardError
  def message = super
  def to_s = "T1-to_s"
end
class T2 < StandardError; def message = super; end
class T3 < T2; def to_s = "T3:" + super; end
p T1.new("t1").message, T2.new("t2").message, T3.new("t3").message

# a default that reads a global or a constant, declared after the text
# dispatchers
$n9 = 0
CONST9 = "c9"
class P9 < StandardError; def message(x = ($n9 += 1)) = super() + x.to_s; end
class Q9 < StandardError; def message(x = CONST9) = super() + x; end
p [P9.new("p"), Q9.new("q"), RuntimeError.new("r")].map(&:message), $n9

# overrides with keyword and block parameters beside one that answers no
# String (the boxed dispatchers fill defaults too)
class KA < StandardError; def message(k: 2) = super() * k; end
class KB < StandardError; def message(&b) = (b ? b.call : super()); end
class KC < StandardError; def message(*r) = "C" + r.size.to_s + super(); end
p [KA.new(+"a"), KB.new(+"b"), KC.new(+"c")].map(&:message)
