# Float#rationalize(eps) takes eps.abs before converting it, so an epsilon
# without abs raises NoMethodError, on a literal, boxed or nullable Float.
# A nil receiver evaluates the epsilon and ignores it.
begin
  p 1.25.rationalize(nil)
rescue => e
  p [e.class, e.message]
end
begin
  p 1.25.rationalize(true)
rescue => e
  p [e.class, e.message]
end

[nil, 1.25].each do |value|
  [nil, true, false, "x", :small, [], {}].each do |epsilon|
    begin
      p value.rationalize(epsilon)
    rescue => e
      p [e.class, e.message]
    end
  end
end
[nil, 1.25].each do |value|
  [0.1, -0.1, 0, Rational(1, 10), Complex(0.1, 0.1)].each do |epsilon|
    begin
      p value.rationalize(epsilon)
    rescue => e
      p [e.class, e.message]
    end
  end
end

[false, true].each do |present|
  value = nil
  value = 1.25 if present
  [nil, true, Complex(0.1, 0.1)].each do |epsilon|
    begin
      p value.rationalize(epsilon)
    rescue => e
      p [e.class, e.message]
    end
  end
  p value.rationalize(0.1), value.rationalize(-0.1), value.rationalize(0)
  p value.rationalize(Rational(-1, 10))
  begin
    p value.rationalize(Object.new)
  rescue => e
    p [e.class, e.message]
  end
end

def receiver
  puts "receiver"
  [nil, 1.25, :unused][1]
end
def epsilon
  puts "epsilon"
  GC.start
  nil
end
begin
  p receiver.rationalize(epsilon)
rescue => e
  p [e.class, e.message]
end
value = [1.25][0]
begin
  p value.rationalize(epsilon)
rescue => e
  p [e.class, e.message]
end
value = [1.25][1]
p value.rationalize(epsilon)
