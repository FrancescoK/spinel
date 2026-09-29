class Callback
  def arity = 3
  def call(x) = "cb#{x}"
  def lambda? = "never"
end

class Named
  def arity = "three"
end

class Stack
  def size = "big"
  def length = :long
end

class Label
  def to_s = 42
end

class Bare; end

def ar(m) = m.arity
def nar(m) = m.arity
def cl(m) = m.call(5)
def lm(m) = m.lambda?
def sz(m) = m.size
def ln(m) = m.length
def ts(m) = m.to_s

p ar(Callback.new)
p ar(proc { |x| x })
p ar(lambda { |a, b| a })
p ar(1.method(:+))
p nar(Named.new)
p nar(proc { |a, b, c| a })
p nar(method(:cl))
p cl(Callback.new)
p cl(proc { |x| x * 2 })
p cl(2.method(:+))
p lm(Callback.new)
p lm(lambda { |x| x })
p lm(proc { |x| x })
p sz(Stack.new)
p sz([1, 2, 3])
p sz("abcd")
p sz(1..4)
p ln(Stack.new)
p ln([1, 2])
p ln("xyz")
p ts(Label.new)
p ts([1, 2])
p ts(:sym)

[Bare.new, 7].each do |v|
  begin
    ar(v)
  rescue NoMethodError => e
    puts e.message
  end
end
begin
  sz(Bare.new)
rescue NoMethodError => e
  puts e.message
end
