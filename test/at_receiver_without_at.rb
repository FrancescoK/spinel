def try
  p yield
rescue NoMethodError => e
  puts e.message
end

def read_s(o) = o.at("k")
def read_y(o) = o.at(:k)
def read_i(o) = o.at(0)
def read_f(o) = o.at(1.5)
try { read_s({"k" => 7}) }
try { read_y({k: 7}) }
try { read_i({0 => 7}) }
try { read_i("str") }
try { read_f({1.5 => 2}) }

def poly_s(o) = o.at("k")
try { poly_s({"k" => 7}) }
def poly_y(o) = o.at(:k)
try { poly_y({k: 8}) }
try { poly_y(3) }
def poly_i(o) = o.at(1)
try { poly_i({1 => 9}) }
try { poly_i([4, 5]) }
try { poly_i("ab") }

h = {"a" => 1}
try { h.at("a") }
s = "xyz"
try { s.at(0) }
try { :sym.at(0) }
try { 5.at(0) }
try { nil.at(0) }
a = [1, 2, 3]
try { a.at(1) }
try { a.at(-1) }
try { [[1], [2]].at(1) }

def sn(o) = o&.at(0)
p sn(nil)
p sn([9])
begin
  sn({0 => 1})
  puts "no raise"
rescue NoMethodError => e
  puts e.message
end

def stmt(o)
  o.at(1)
  :done
end
p stmt([1, 2])
begin
  stmt("ab")
rescue NoMethodError => e
  puts e.message
end

def sum_at(o, i) = o.at(i) + 1
p sum_at([1, 2], 1)
begin
  sum_at({1 => 2}, 1)
rescue NoMethodError => e
  puts e.message
end
def fl(o) = o.at(0)
p fl([1.5])
p fl([[1, 2]])
p fl([:a, "b"])
begin
  fl(:sym)
rescue NoMethodError => e
  puts e.message
end
hh = {0 => 1}
begin
  p hh&.at(0)
rescue NoMethodError => e
  puts e.message
end
nn = nil
p nn&.at(0)
def hs(o) = o&.at("k")
p hs(nil)
p hs({"k" => 1}) rescue p $!.class
