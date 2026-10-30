# A Symbol read out of a mixed Array answers id2name with its name, as to_s
# does (frozen in Spinel, so the mutation takes a copy); a value of another
# kind still has no id2name.
x = [:hello, 1][0]
p x.id2name
p x.id2name.upcase
s = x.id2name.dup
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
