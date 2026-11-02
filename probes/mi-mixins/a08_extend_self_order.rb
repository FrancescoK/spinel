module M
  extend self
  def a = 1
  p a
  p((b rescue :nameerr))
  def b = 2
  p b
end
p M.a, M.b
