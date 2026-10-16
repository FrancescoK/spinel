# A parameter holds an Array of Strings that a String of it changes in place,
# or nil. A new String (`+"x"`) appended to it is run before the nil test, as
# CRuby runs an argument before the call raises, and the Array takes it.
def mk(f)
  t = +"t"
  a = [t]
  t << "!"
  f ? a : nil
end

def w(x)
  x << +"x"
  x.first << +"z"
end

r = mk(true)
w(r)
p r
begin
  w(mk(false))
rescue NoMethodError
  puts "nme"
end
