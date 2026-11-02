# included: hook defined before the include (baseline)
module M
  def self.included(b) = puts("inc #{b}")
end
class A
  include M
end
puts "done"
