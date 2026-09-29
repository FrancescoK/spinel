class B
  def m = 1
  alias a1 m
  alias a2 m
  def a1 = 9
  def m = 2
end
b = B.new
p b.a1, b.a2, b.m
