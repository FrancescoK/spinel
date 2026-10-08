# Conditional assignment distinguishes nil from an empty String in boxed,
# plain String and mutable-handle slots, including a proc's boxed arguments.
# spinel: gc-minor
c = [nil, "x"][ARGV.size]
s = c
s ||= +"b"
p s

def string_or_nil
  ["x"][ARGV.size + 1]
end

def string_assignments(value)
  s = value
  s ||= +"b"
  p s
  s = value
  p(s ||= +"b")
  p s
  s = value
  s &&= +"b"
  p s
  s = value
  p(s &&= +"b")
  p s

  s2 = +"other"
  s = value
  s ||= s2
  p s
  s = value
  p(s ||= s2)
  s = value
  p(s &&= s2)

  @s = value
  @s ||= +"b"
  p @s
  @s = value
  p(@s ||= +"b")
  p @s
  @s = value
  @s &&= +"b"
  p @s
  @s = value
  p(@s &&= +"b")
  p @s

  $s = value
  $s ||= +"b"
  p $s
  $s = value
  p($s ||= +"b")
  p $s
  $s = value
  $s &&= +"b"
  p $s
  $s = value
  p($s &&= +"b")
  p $s

  h = { k: value }
  h[:k] ||= +"b"
  p h[:k]
  h[:k] = value
  p(h[:k] ||= +"b")
  p h[:k]
  h[:k] = value
  h[:k] &&= +"b"
  p h[:k]
  h[:k] = value
  p(h[:k] &&= +"b")
  p h[:k]
end
string_assignments(string_or_nil)
string_assignments("")
string_assignments("x")

class ConditionalString
  def run(value)
    @s = value
    @s ||= +"b"
    p @s
    @s = value
    p(@s ||= +"b")
    @s = value
    @s &&= +"b"
    p @s
    @s = value
    p(@s &&= +"b")
  end
end
slot = ConditionalString.new
slot.run(string_or_nil)
slot.run("")
slot.run("x")

m = string_or_nil
m ||= +"b"
p m
m = string_or_nil
p(m ||= +"b")

# Capturing the parameter for mutation gives it a String-handle slot in
# both builds. A passed nil must arrive as NULL, just like an omitted arg.
or_assign = proc do |s|
  append = proc { s << "!" }
  p s
  s ||= +"b"
  p s
  append.call
  p s
end
or_assign.call(string_or_nil)
or_assign.call
or_assign.call(+"")
or_assign.call(+"x")

or_value = proc do |s|
  append = proc { s << "!" }
  s2 = +"other"
  p(s ||= s2)
  append.call
  p s
end
or_value.call(string_or_nil)
or_value.call(+"")
or_value.call(+"x")

and_value = proc do |s|
  append = proc { s << "!" if s }
  p(s &&= +"b")
  append.call
  p s
end
and_value.call(string_or_nil)
and_value.call
and_value.call(+"")
and_value.call(+"x")

# The right side runs once only when the assignment is taken.
def replacement
  puts "rhs"
  +"b"
end
s = string_or_nil
p(s &&= replacement)
p(s ||= replacement)
p(s ||= replacement)
s = +""
p(s ||= replacement)
p(s &&= replacement)
