# A call on an instance variable a write of the program leaves nil raises
# NoMethodError as CRuby does (#9347): the release build left every ivar
# untested (#5960), and the call answered a default (`<<` pushed nothing,
# `size` answered 0) or crashed. A slot only other writes fill stays untested.
class Q
  def initialize(f) = (@r = f ? [1, "a"] : nil)
  def add(x) = (@r << x; :pushed)
  def n = @r.size
end
q = Q.new(false)
begin; p q.add(2); rescue NoMethodError => e; puts e.message; end
begin; p q.n;      rescue NoMethodError => e; puts e.message; end
q2 = Q.new(true)
p q2.add(3), q2.n
class S
  def initialize(f) = (@s = f ? +"ab" : nil; @h = f ? {"k" => 1} : nil; @i = f ? [1, 2] : nil)
  def up = @s.upcase
  def ap = (@s << "x"; @s)
  def hk = @h.keys
  def hs = @h.size
  def ii = @i.sum
  def ip = (@i.push(3); @i)
end
%i[up ap hk hs ii ip].each do |m|
  begin; p S.new(false).send(m); rescue NoMethodError => e; puts e.message; end
  p S.new(true).send(m)
end
