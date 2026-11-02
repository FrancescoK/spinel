module M
  def self.included(base) = (puts "included in #{base.inspect}")
  def hi = "M"
end
class K
  class << self
    include M
  end
end
p K.hi
