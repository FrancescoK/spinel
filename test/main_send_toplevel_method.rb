def m(a, b = 2) = a + b
def yielder(x) = yield(x)

class Own
  def m(a, b = 2) = a * 100
end

class Plain
  def go(n) = send(n, 1)
end

NAMES = %i[m yielder]

p send(NAMES[0], 1)
p send("m", 1, 5)
p send(NAMES[1], 3) { |v| v * 10 }
p __send__(NAMES[0], 9)

def inside(n) = send(n, 4)
p inside(NAMES[0])

p Plain.new.go(NAMES[0])
p Plain.new.send(NAMES[0], 3)
p Own.new.send(NAMES[0], 2)
p Own.new.public_send(NAMES[0], 2)

p respond_to?(NAMES[0], true)
p respond_to?(NAMES[0])
p respond_to?(:m, true)
p respond_to?(:m)
p self.respond_to?(NAMES[0], true)
p Plain.new.respond_to?(NAMES[0], true)
p Plain.new.respond_to?(NAMES[0])

def asks(n) = respond_to?(n, true)
p asks(NAMES[0])

begin
  public_send(NAMES[0], 1)
rescue NoMethodError => e
  puts e.message
end

begin
  public_send(:m, 1)
rescue NoMethodError => e
  puts e.message
end

def pub_inside(n)
  public_send(n, 1)
rescue NoMethodError => e
  e.message
end
p pub_inside(NAMES[0])

begin
  Plain.new.public_send(:m, 3)
rescue NoMethodError => e
  puts e.message
end
