# included: a hook with an early return
module M
  def self.included(b)
    return if b.name == "A"
    puts "inc #{b}"
  end
end
class A; include M; end
class B; include M; end
