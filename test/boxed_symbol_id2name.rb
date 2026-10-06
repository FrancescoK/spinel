# A Symbol read out of a mixed Array answers id2name with its name, a new
# String like to_s; a value of another kind still has no id2name.
x = [:hello, 1][0]
p x.id2name
p x.id2name.upcase
s = x.id2name
s << "!"
p s
p x
p [:"with space", 1][0].id2name
begin
  [1, :a][0].id2name
rescue NoMethodError => e
  puts e.message
end
begin
  [nil, :a][0].id2name
rescue NoMethodError => e
  puts e.message
end
