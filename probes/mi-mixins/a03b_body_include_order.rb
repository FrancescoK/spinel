module M
  def hi = "M"
end
class K
  def self.check = new.respond_to?(:hi)
end
p K.check
class K
  include M
end
p K.check
