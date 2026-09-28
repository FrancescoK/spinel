$log = []
def key(k)
  $log << k
  k
end
def rd(o) = o.at(key(0))
p rd([5, 6])
begin
  rd({0 => 1})
rescue NoMethodError => e
  puts e.message
end
begin
  rd("ab")
rescue NoMethodError => e
  puts e.message
end
def rs(o) = o.at(key("k"))
begin
  rs({"k" => 1})
rescue NoMethodError => e
  puts e.message
end
begin
  rs(:k)
rescue NoMethodError => e
  puts e.message
end
def ty(h) = h.at(key(:t))
begin
  ty({t: 1})
rescue NoMethodError => e
  puts e.message
end
p $log
