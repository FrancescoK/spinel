# Writing to a frozen OpenStruct raises FrozenError with the receiver's
# inspect: a new member fails on the OpenStruct, an existing one on the
# Hash that holds its members.
require "ostruct"

def try
  yield
  puts "no error"
rescue => e
  p [e.class, e.message]
end

o = OpenStruct.new(a: 1, b: "x").freeze
try { o[:c] = 2 }
try { o.c = 2 }
try { o["d"] = 3 }
try { o[:a] = 2 }
try { o.a = 2 }
try { o["b"] = 3 }
p o
p o.frozen?

# an empty one, and one read out of a container
e = OpenStruct.new.freeze
try { e.x = 1 }
x = [o, 0][0]
try { x[:z] = 1 }
try { x[:a] = 1 }

# the receiver of the error
begin
  o.z = 1
rescue FrozenError => err
  p err.receiver
end
begin
  o.a = 1
rescue FrozenError => err
  p err.receiver
end

# the receiver of an existing member's error is the member table, frozen with
# the OpenStruct
o2 = OpenStruct.new(a: 1).freeze
begin
  o2.a = 2
rescue FrozenError => err
  p err.receiver.frozen?
end
p o2

# an OpenStruct that holds itself renders as the ellipsis in the message
self_ref = OpenStruct.new(a: 1)
self_ref.me = self_ref
self_ref.freeze
begin
  self_ref.zz = 1
rescue FrozenError => err
  puts err.message
end

# a frozen OpenStruct held only by the call: the message and the receiver
# survive the allocations of the raise and of a later loop
def mk(n)
  o = OpenStruct.new
  n.times do |i|
    key = "k#{i}"
    val = ("v" * 40) + i.to_s
    o[key] = val
  end
  o[:nest] = OpenStruct.new(x: 1, y: OpenStruct.new(z: "deep" * 30, arr: [1, "two", :three, 4.5]))
  o.freeze
end
def churn
  a = []
  200.times { |i| a.push(OpenStruct.new(j: i, s: ("junk#{i}" * 5))) }
  a.size
end
begin
  mk(30).k7 = 5
rescue FrozenError => fe
  msg = fe.message
  churn
  rc = fe.receiver
  p rc.class, rc.size, rc.inspect.size, msg == "can't modify frozen Hash: " + rc.inspect
end
begin
  mk(30).newmember = 5
rescue FrozenError => fe
  msg = fe.message
  churn
  rc = fe.receiver
  p rc.class, rc.inspect.size, msg == "can't modify frozen OpenStruct: " + rc.inspect
end
