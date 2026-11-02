# included: fires after the module is appended, before the next statement
module M
  def self.included(b) = puts("inc #{b.include?(M)}")
end
class A
  puts "before"
  include M
  puts "after"
end
