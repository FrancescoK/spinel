# A conversion over a boxed receiver's call whose arms answer a String
# keeps nil's own answer: a reader of an ivar that may hold nil answers
# nil, and its to_s is "" (to_str raises), not the nil the arms boxed.
class A
  def initialize(d)
    @d = d
  end

  def d
    @d
  end
end

class B
  def initialize(d)
    @d = d
  end

  def d
    @d
  end
end

def show(v)
  v += "?"
  puts v
end

class Holder
  def initialize
    @s = nil
  end

  def take(x)
    @s = x.d.to_s
    @s += "#"
    puts @s
  end
end

[A.new(nil), A.new("y")].each do |x|
  s = x.d.to_s
  s += "!"
  puts s
end

[A.new(nil), B.new("y"), A.new("z"), B.new(nil)].each do |x|
  s = x.d.to_s
  s += "!"
  puts s
  t = (1; x.d.to_s)
  t += "."
  puts t
  p x.d.itself
  p x.d&.to_s
  v = x.d.itself.to_s
  v += "+"
  puts v
  show(x.d.to_s)
  Holder.new.take(x)
  begin
    r = x.d.to_str
    r += "~"
    puts r
  rescue NoMethodError => e
    puts e.class
  end
end
