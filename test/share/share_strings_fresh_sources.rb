# Under --share-strings the seal lets a copy of a shared String's class
# through where the String is new by where it comes from, since no other
# name can see the copy. These answered right and were refused once the
# seal checked every route: StringIO#read's String (which the package now
# declares new) kept through a conditional in readpartial, a fallback to
# ENV's to_s, a StringIO's own String read through #string, and a proc
# read out of an Array or a Method handed to map with `&`.
require "stringio"

def fallback(prefix)
  return prefix if prefix != ""
  d = ENV["SPINEL_NO_SUCH_VAR_FRESH"].to_s
  return d if d != ""
  File.join("home", "bin")
end
seen = []
a = +"pre"
seen << a
x = fallback(a)
x << "!"
p a, x, x.equal?(a), seen
y = fallback(+"")
y << "?"
p y, seen

io = StringIO.new(+"hello world")
r = io.readpartial(5)
r << "!"
p r, io.string
w = StringIO.new(+"abc")
s = w.string
w.write("Z")
s << "."
p s, w.string

h = { a: 1, b: 2 }
kv = [proc { |k, v| "#{k}=#{v}" }, 1][0]
def pair(k, v) = "#{k}:#{v}"
mm = method(:pair)
ew = [proc { |(k, v), memo| memo << k }, 1][0]
p h.map(&kv), h.map(&mm), h.each_with_object([], &ew)
