# A String bang or append on an element read whose index runs code
# (`arr[id(0)].upcase!`): the element is no slot to read again, and the
# bang went to a copy of its bytes, so the String in the Array (and every
# other name for it) never changed.
def id(x) = x
b = +"aab"
arr = [b]
arr[id(0)].upcase!
p b
arr[id(0)] << "!"
p b
p arr[id(0)].downcase!
p arr[id(0)].downcase!
p b
h = { "k" => b }
h[id("k")].squeeze!
p b
begin
  arr[id(3)].upcase!
rescue NoMethodError => e
  p e.class
end
