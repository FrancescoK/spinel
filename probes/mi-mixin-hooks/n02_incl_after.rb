# included: hook added (module reopened) after the first include; only the later include fires
module M; end
class A
  include M
end
module M
  def self.included(b) = puts("inc #{b}")
end
class B
  include M
end
puts "done"
