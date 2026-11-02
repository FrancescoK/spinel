# included: the hook extends the base with a module that declares attrs
module Conf
  attr_accessor :level
end
module M
  def self.included(b) = b.extend(Conf)
end
class A
  include M
  self.level = 3
end
p A.level
