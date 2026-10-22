# A Method of String#[] bound to a String that is appended to (its handle)
# takes one or two arguments, as one bound to any other String does.
s = String.new("hello")
s << "!"
m = s.method(:[])
p m.call(1), m.call(1, 3)
begin
  m.call(0, 2, 3)
rescue ArgumentError => e
  puts e.message
end
