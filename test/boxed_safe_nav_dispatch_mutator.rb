# A mutator called through `&.` on the answer of a method of a receiver of
# several classes: `px.pick(s)&.<<("!")` where one class answers the String
# it was given and another answers nil or a new String. The change lands in
# the given String when that class is the receiver, and in the new String
# (which nothing else holds) when the other is; the guard that tested for
# nil held a copy of the answer's bytes, so the given String kept its text.
# The same call without `&.`, through a local, and with its answer shown
# are written beside it; `r&.<<("!")` on a local that holds nil is a no-op,
# also where the local is a conditional's nil beside the String itself.
class Same
  def pick(t) = t
end

class Nothing
  def pick(t) = nil
end

class Fresh
  def pick(t) = +"fresh"
end

def append(px)
  s = +"abc"
  px.pick(s)&.<<("!")
  p s
end

def upcase(px)
  s = +"abc"
  px.pick(s)&.upcase!
  p s
end

def concat(px)
  s = +"abc"
  px.pick(s)&.concat("!", "?")
  p s
end

def shown(px)
  s = +"abc"
  p px.pick(s)&.<<("!")
  p s
  s = +"abc"
  p px.pick(s)&.upcase!
  p s
  s = +"abc"
  p px.pick(s)&.concat("!", "?")
  p s
end

def plain(px)
  s = +"abc"
  px.pick(s) << "!"
  p s
end

def via_local(px)
  s = +"abc"
  r = px.pick(s)
  r&.<<("!")
  p s
end

def ternary(flag)
  s = +"abc"
  r = flag ? nil : s
  r&.<<("!")
  r&.upcase!
  p s
end

[Same.new, Nothing.new, Fresh.new].each do |px|
  append(px)
  shown(px)
  upcase(px)
  concat(px)
  via_local(px)
  plain(px) unless px.is_a?(Nothing)
end

ternary(true)
ternary(false)

begin
  plain(Nothing.new)
rescue NoMethodError => e
  puts e.class
end
