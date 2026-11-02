module N
  def n = :n
end
module M
  extend self
  include N
  def a = :inst
  def self.a = :own
  attr_accessor :z
end
p M.a
p M.n
M.z = 3
p M.z
class C; include M; end
p C.new.a
