# included: the hook calls super (Module#included)
module M
  def self.included(b)
    r = super
    puts "inc #{b} #{r.inspect}"
  end
end
class A; include M; end
