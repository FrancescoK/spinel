# alias_method returns the new name as a Symbol
class A
  def b = 1
  r = alias_method :a, :b
  p r
  p(alias_method :c, :b)
  class << self
    def k = 3
    r = alias_method :kk, :k
  end
end

module M
  def m = 2
  @n = alias_method :mm, :m
  p @n
end

class B
  include M
end

p A.new.a
p A.new.c
p A.kk
p B.new.mm
