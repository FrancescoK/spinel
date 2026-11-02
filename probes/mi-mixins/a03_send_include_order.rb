module M
  def hi = "M"
end
class K
  def self.check = new.respond_to?(:hi)
end
p K.check
K.send(:include, M)
p K.check
K.extend(M)
p K.hi
