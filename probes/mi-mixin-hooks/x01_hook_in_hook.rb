# inherited hook includes a module whose included hook fires
module M
  def self.included(b) = puts("inc #{b}")
end
class B
  def self.inherited(k)
    puts "inh #{k}"
    k.include(M)
  end
end
class C < B; end
puts C.include?(M)
