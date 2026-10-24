# A define_method an `each` over literals unrolls reads the loop variable as
# each element's literal, also where its body hands it to a call (as an
# argument or a receiver): the variable was taken for a slot that holds a
# String's handle, and the C read a local the method does not have (#10108).
class Foo
  def foo(x) = "got:#{x}"
  def bar(a, b) = "#{a}-#{b}"

  %w[alpha beta].each do |n|
    define_method(n) { foo(n) }
  end
  %w[gamma delta].each do |n|
    define_method(n) { n.to_s + "!" }
  end
  %i[up down].each do |s|
    define_method("#{s}_pair") { bar(s, s.to_s.upcase) }
  end
  %w[one two].each do |n|
    define_method("#{n}_with") { |x| bar(n, x) }
  end
end

# the loop in a class method, which defines them when it is called: the
# loop variable is a local of that method as well
class Bar
  def self.setup
    %w[x y].each { |n| define_method(n) { show(n) } }
  end
  def show(v) = "v=#{v}"
  setup
end

f = Foo.new
puts f.alpha, f.beta, f.gamma, f.delta, f.up_pair, f.down_pair
puts f.one_with("a"), f.two_with("b")
puts Bar.new.x, Bar.new.y
