# A Hash built from a nullable number widens after the main fixpoint. Its
# return type, callers' locals and parameters must follow that widening.
def pack(value)
  {"n" => value}
end

def relay(value)
  pack(value)
end

def through_local(value)
  h = relay(value)
  h
end

def read_number(h)
  h["n"]
end

def read_keyword(h:)
  h["n"]
end

p relay([1][1])
p relay([1][0])
p through_local([1][1])
p read_number(through_local([1][1]))
p read_number(through_local([1][0]))
p read_keyword(h: through_local([1][1]))
p read_keyword(h: through_local([1][0]))

def increment(value)
  value + 1
end

begin
  p increment(read_number(through_local([1][1])))
rescue NoMethodError => e
  puts e.class
end
p increment(read_number(through_local([1][0])))

def pack_float(value)
  {"n" => value}
end

def relay_float(value)
  pack_float(value)
end

p relay_float([1.5][1])
p relay_float([1.5][0])
