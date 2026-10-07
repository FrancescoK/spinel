# Flag-only: a class method answering its class variable's shared String,
# called on its class, hands the caller the handle (the deep-return pickup)
# even where another class has a method of the same name. The pickup asked
# for a uniquely named method, so `t = A.x` took a copy and `t << "?"` did
# not reach A's String.
class A
  @@x = +"a"
  def self.x = @@x
end
class C
  def self.x = 1
end
t = A.x
t << "?"
p A.x, C.x
class D
  @@y = +"d"
  def self.x = @@y
end
u = D.x
u << "!"
p D.x, A.x
