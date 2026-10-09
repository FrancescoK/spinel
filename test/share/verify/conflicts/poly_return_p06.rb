# returns self (String receiver reopen) and parameter
module M
  def pick(s) = @k ? s : @x
end
class A; include M; def initialize(x, k) = (@x = x; @k = k); end
class B; def pick(s) = s + "b"; end
src = "s".dup; arg = "a".dup
os = [A.new(src, true), A.new(src, false), B.new]
w = [os[0].pick(arg), os[1].pick(arg), os[2].pick(arg)]
w[0] << "!"
w[1] << "?"
p w, src, arg
