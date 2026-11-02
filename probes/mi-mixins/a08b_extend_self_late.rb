module M
  def a = 1
  p((M.a rescue :nomethod))
  extend self
  p M.a
end
