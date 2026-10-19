# IO::Buffer's writing operations answer what CRuby's do -- set_value and
# set_values the offset just past the value(s), set_string and copy the
# byte count, clear / and! / or! / xor! / not! the buffer -- and on a slice
# whose root was freed or shrunk under it they raise InvalidatedError with
# the WRITE message, "Buffer is invalid!", even for a zero-length write,
# while the reads keep "Buffer has been invalidated!". Every value here fits
# a 32-bit Integer; the 64-bit ones past it are io_buffer_write_answers_int64.rb.

def try(label)
  puts "#{label}: #{yield}"
rescue => e
  puts "#{label}: #{e.class}: #{e.message}"
end

b = IO::Buffer.new(32)

# set_value: a literal type with an Integer / Float (the typed setters)
puts b.set_value(:U8, 1, 10)
puts b.set_value(:S8, 31, -1)
puts b.set_value(:u16, 2, 500)
puts b.set_value(:S16, 30, -500)
puts b.set_value(:u32, 4, 70000)
puts b.set_value(:S32, 28, -70000)
puts b.set_value(:u64, 8, 70000)
puts b.set_value(:S64, 24, -70000)
puts b.set_value(:f32, 4, 1.5)
puts b.set_value(:F64, 8, 2.25)
puts b.set_value(:f64, 16, 3)

# ... with a boxed value (the boxed typed setter)
[7, 1.5, -3].each_with_index { |v, i| puts b.set_value(:u64, 8 * i, v) }

# ... with a type only known at run time (the generic entry)
[:U8, :s16, :U32, :s64, :F32, :f64].each { |t| puts "#{t} #{b.set_value(t, 3, 1)}" }

# set_values chains the offsets; an empty list answers the offset given
puts b.set_values([:U8, :u16, :u32], 2, [1, 2, 3])
puts b.set_values([:F64, :S8], 20, [1.5, -1])
puts b.set_values([], 3, [])
puts b.set_values([], 100, [])
try("set_values negative offset") { b.set_values([:U8], -1, [1]) }
try("set_values empty, negative offset") { b.set_values([], -1, []) }
try("set_values negative offset, values not an Array") { b.set_values([:U8], -1, 1) }
try("set_values negative offset, lengths differ") { b.set_values([:U8], -1, [1, 2]) }
try("set_values negative offset, types not an Array") { b.set_values(:U8, -1, [1]) }

# set_string and copy answer the byte count
puts b.set_string("abc")
puts b.set_string("abc", 5)
puts b.set_string("abcdef", 5, 2)
puts b.set_string("abcdef", 5, 2, 3)
puts b.set_string("", 4)
src = IO::Buffer.new(4)
puts b.copy(src)
puts b.copy(src, 3)
puts b.copy(src, 3, 2)
puts b.copy(src, 3, 2, 1)
puts b.copy(IO::Buffer.new(0), 1)

# the in-place operations answer the buffer itself
mask = IO::Buffer.new(2)
puts b.clear.equal?(b)
puts b.clear(1, 4).equal?(b)
puts b.and!(mask).equal?(b)
puts b.or!(mask).equal?(b)
puts b.xor!(mask).equal?(b)
puts b.not!.equal?(b)

# a slice of a freed root, and one past the end of a shrunk root
freed_root = IO::Buffer.new(16)
freed = freed_root.slice(4, 4)
freed_root.free
shrunk_root = IO::Buffer.new(16)
shrunk = shrunk_root.slice(8, 8)
shrunk_root.resize(4)
other = IO::Buffer.new(4)

def writes(name, s, other)
  puts "-- #{name}"
  try("set_value") { s.set_value(:U8, 0, 1) }
  try("set_value bad type") { s.set_value(:X8, 0, 1) }
  try("set_value past end") { s.set_value(:u32, 100, 1) }
  try("set_values") { s.set_values([:U8], 0, [1]) }
  try("set_values empty") { s.set_values([], 0, []) }
  try("set_string") { s.set_string("a") }
  try("set_string empty") { s.set_string("") }
  try("set_string neg offset") { s.set_string("a", -1) }
  try("copy") { s.copy(other) }
  try("copy empty") { s.copy(IO::Buffer.new(0)) }
  try("clear") { s.clear }
  try("clear zero") { s.clear(0, 0, 0) }
  try("clear offset past end") { s.clear(0, 100) }
  try("and!") { s.and!(other) }
  try("or!") { s.or!(other) }
  try("xor!") { s.xor!(other) }
  try("not!") { s.not! }
  # reads keep their own message
  try("get_value") { s.get_value(:U8, 0) }
  try("get_string") { s.get_string }
  try("copy from it") { other.copy(s) }
  try("and! by it") { other.and!(s) }
  try("copy from it, bad offset") { other.copy(s, -1) }
end
writes("freed", freed, other)
writes("shrunk", shrunk, other)

# a read-only buffer still says so first
ro = IO::Buffer.for("abcd")
try("ro set_value") { ro.set_value(:X8, 0, 1) }
try("ro set_values") { ro.set_values([], 0, []) }
try("ro set_string") { ro.set_string("a") }
try("ro copy") { ro.copy(other) }
try("ro copy from shrunk") { ro.copy(shrunk) }
try("ro clear") { ro.clear(0, 0, 0) }
try("ro clear offset past end") { ro.clear(0, 5) }
try("ro not!") { ro.not! }
