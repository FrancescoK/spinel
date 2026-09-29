# Every alias taken before a method is redefined names the definition in
# effect at the alias, including a second alias of the same method and an
# alias of an attribute reader.
class A
  def m = 20
  alias a1 m
  alias a2 m
  def m = 200
end
p A.new.a1, A.new.a2, A.new.m

class B
  def m = 1
  alias_method :b1, :m
  alias b2 m
  alias b3 b1
  def m = 2
  alias b4 m
  def m = 3
end
b = B.new
p b.b1, b.b2, b.b3, b.b4, b.m

module M
  def m = 1
  alias a1 m
  alias_method :a2, :m
  def m = 2
end
class K
  include M
end
k = K.new
p k.a1, k.a2, k.m

class R
  def m = 1
  alias a1 m
  alias a2 m
  def m = 2
  def via = a2
end
p R.new.a1, R.new.via, R.new.m

class T
  attr_reader :v
  def initialize = @v = 4
  alias v1 v
  alias_method :v2, :v
  def v = 40
end
p T.new.v1, T.new.v2, T.new.v

def tm = 1
alias ta tm
alias tb tm
def tm = 2
p ta, tb, tm
