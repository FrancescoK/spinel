# A conversion of a String Array element past the end, kept in a variable:
# nil's to_s is a frozen "", its to_str raises, its itself stays nil, in
# every String representation.
a = ["x"]
v = a[5].to_s
p v, v.length, v.frozen?
begin
  t = a[5].to_str
  p t
rescue NoMethodError => e
  puts e.class
end
u = a[5].itself
p u
w = a[0].to_s
p w
b = [+"q"]
s = b[0].to_s << "z"
p s, b
# ...and a safe-navigation conversion skips the nil element instead.
x = a[5]&.to_s
p x
y = a[5]&.to_str
p y
