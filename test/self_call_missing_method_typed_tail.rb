# A method whose tail is a self-call its class does not have (another class
# defines the name) raises NoMethodError when that branch runs, and the
# method still answers its other branch's type: a String, an Array, an
# Integer. The raising call answers no type of its own.

class Other
  def receiver(a, b) = [a, b]
  def pick(a) = a
  def count_of(a) = a
end

class Checker
  def key(x, buf)
    if x
      receiver(x, buf)
    else
      buf << "a"
    end
  end

  def items(x)
    x ? pick(x) : [1, 2]
  end

  def size(x)
    return count_of(x) if x
    3
  end
end

chk = Checker.new
p chk.key(nil, +"z")
p chk.items(nil)
p chk.size(nil)
[-> { chk.key(1, +"z") }, -> { chk.items(1) }, -> { chk.size(1) }].each do |f|
  f.call
rescue NoMethodError => e
  puts e.message
end
p Other.new.receiver(1, 2)
