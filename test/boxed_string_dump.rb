# dump on a String held in a mixed Array (a boxed receiver) answers its
# quoted form, as on a String; another kind of value raises NoMethodError.
s = [+"Hi \"x\"\n\t\\", 1][0]
p s.dump, s.dump.size
puts s.dump
x = [2, +"a"][0]
begin
  x.dump
rescue NoMethodError => e
  puts e.message
end
