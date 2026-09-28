# merge!/update of a hash with boxed values through a hash parameter
def m(h) = h.merge!({"z" => :s})
p m({"a" => 1})
p m({1 => 1})

def u(h) = h.update({"z" => 1.5})
p u({"a" => 1})
p u({a: 1})

def one(h) = h.merge!({"k" => :v})
x = {"b" => 2}
one(x)
p x

def two(h) = h.update({1 => "i"}, {2 => :j})
y = {3 => 4}
two(y)
p y
