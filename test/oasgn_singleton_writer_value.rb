# Attribute assignments answer the assigned value, not the singleton writer's return.
a = Class.new { attr_accessor :b }.new
def a.b=(x)
  :v
end
a.b = false
p(a.b ||= 20)
p a.b

b = Class.new { attr_accessor :b }.new
def b.b=(x)
  @b = x
  :v
end
b.b = false
p(b.b &&= 30)
p b.b
b.b = 10
p(b.b &&= 30)
p b.b
p(b.b ||= 40)
p b.b

c = Class.new { attr_accessor :b }.new
def c.b=(x)
  @b = x
  :v
end
c.b = 10
p(c.b += 5)
p c.b

@or_receiver = Class.new { attr_accessor :b }.new
def @or_receiver.b=(x)
  :v
end
@or_receiver.b = false
p(@or_receiver.b ||= 20)
p @or_receiver.b

@and_receiver = Class.new { attr_accessor :b }.new
def @and_receiver.b=(x)
  @b = x
  :v
end
@and_receiver.b = false
p(@and_receiver.b &&= 30)
p @and_receiver.b
@and_receiver.b = 10
p(@and_receiver.b &&= 30)
p @and_receiver.b
p(@and_receiver.b ||= 40)
p @and_receiver.b

@op_receiver = Class.new { attr_accessor :b }.new
def @op_receiver.b=(x)
  @b = x
  :v
end
@op_receiver.b = 10
p(@op_receiver.b += 5)
p @op_receiver.b
