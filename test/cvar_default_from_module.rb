# a class variable a module declares, read by a method the module defines
# (here a parameter default) on an object of a class including it: the
# method is the class's copy, and the variable is still the module's
module URL
  @@tld_length = 1
  def domain(tld_length = @@tld_length) = "d#{tld_length}"
end
class Request
  include URL
end
def call(obj, name) = obj.send(name)
p call(Request.new, [:domain, :to_s][0])
p Request.new.domain, Request.new.domain(2)
class Other
  include URL
  def tld = @@tld_length
end
p Other.new.domain, Other.new.tld
