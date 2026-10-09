# spinel: share
# spinel: gc-minor
# A builtin's handle route also publishes its value at a method return.
# Mutations in either direction observe the same String after the pickup.
def tapped(s)
  s.tap { |x| String(+"other"); x.size }
end
def converted(s)
  String(s)
end
def constructed_message(s)
  RuntimeError.new(s).message
end
def rescued_message(s)
  raise ArgumentError, s
rescue ArgumentError => e
  e.message
end
def explicit_conversion(s)
  return String(s)
end
def ensured_conversion(s)
  return s.tap { |x| String(+"other"); x.size }
ensure
  10.times { "garbage" * 100 }
end
def conditional_conversion(s, choose)
  choose ? String(s) : nil
end
def mixed_conversion(s, choose)
  choose ? String(s) : +"fresh"
end

# tap
s = +"a\0b"
t = tapped(s)
p t.equal?(s)
t << "c"
p s
s << "d"
p t

# String
s = +"a\0b"
t = converted(s)
p t.equal?(s)
t << "c"
p s
s << "d"
p t

# new message
s = +"a\0b"
t = constructed_message(s)
p t.equal?(s)
t << "c"
p s
s << "d"
p t

# raised message
s = +"a\0b"
t = rescued_message(s)
p t.equal?(s)
t << "c"
p s
s << "d"
p t

# explicit
s = +"a\0b"
t = explicit_conversion(s)
p t.equal?(s)
t << "c"
p s
s << "d"
p t

# ensure
s = +"a\0b"
t = ensured_conversion(s)
p t.equal?(s)
t << "c"
p s
s << "d"
p t

# conditional
s = +"a\0b"
t = conditional_conversion(s, true)
p t.equal?(s)
t << "c"
p s
s << "d"
p t

# mixed
s = +"a\0b"
t = mixed_conversion(s, true)
p t.equal?(s)
t << "c"
p s
s << "d"
p t

p conditional_conversion(+"unused", false)
s = +"unchanged"
fresh = mixed_conversion(s, false)
fresh << "!"
p s, fresh

# Frozen inputs keep their frozen mark, including through a block caller.
1.times do
  source = "fixed"
  value = converted(source)
  p value.equal?(source)
  begin
    value << "!"
  rescue FrozenError
    p source
  end
end

# A conversion may return fresh text rather than a borrowed String.
class ReturnLabel
  def to_s = +"label"
end
def converted_label(value) = String(value)
p converted_label(ReturnLabel.new)

# Identity conversion through a static holder, and a multi-statement block.
def same_source = $source.itself
def then_source(s)
  s.then { |x| x.size; x }
end
$source = +"identity"
t = same_source
t << "!"
p $source
$source << "?"
p t
s = +"then"
t = then_source(s)
t << "!"
p s
s << "?"
p t

# A native answer's route is queried without rendering its block receiver.
require "stringio"
def native_tail(io)
  io.tap { |out| out << "!" }.string
end
io = StringIO.new(+"native")
t = native_tail(io)
p t.equal?(io.string)
t << "?"
p io.string
