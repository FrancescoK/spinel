def ev(object, method, *args)
  case method
  in Symbol => sym
    object.send(sym, *args)
  in Proc => pr
    pr.call(object)
  end
end
p ev(1, :to_s)
p ev(1, proc { |o| o + 1 })

class Foo
  def bar(x = 7) = x * 2
  def first(n = 1) = [:f, n]
  private :first
end

def dyn(o, m, *a) = o.send(m, *a)
p dyn(1, :to_s)
p dyn(255, :to_s, 16)
p dyn([3, 1], :first)
p dyn([3, 1, 4], :first, 2)
p dyn("ab", :center, 5)
p dyn("ab", :center, 5, "*")
p dyn(1.5, :round)
p dyn(1.25, :round, 1)
p dyn(Foo.new, :bar)
p dyn(Foo.new, :bar, 3)
p dyn(Foo.new, :first)
p dyn(Foo.new, :first, 4)

def lit(*a) = 7.send(:to_s, *a)
p lit
p lit(2)
def pad(*a) = "ab".send(:center, *a)
p pad(5)
p pad(5, "*")
def priv(o, *a) = o.send(:first, *a)
p priv(Foo.new)
p priv(Foo.new, 3)
def pub(o, *a) = o.public_send(:first, *a)
begin
  pub(Foo.new, 2)
rescue NoMethodError
  puts "NoMethodError"
end
