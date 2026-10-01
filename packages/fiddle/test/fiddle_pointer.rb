# Fiddle::Pointer: C memory read and written by offset, offsets and
# comparisons, the free function, the module's malloc/realloc/free.
require "fiddle"

m = Fiddle::Pointer.malloc(8)
m[0, 8] = "abcdefg\0"
p m.class, m.size, m.null?
p m.to_s, m.to_s(3), m.to_str, m[1], m[7]
m[0] = 65
p m.to_s(3)
m[0, 1] = "qq"
p m[0, 2]
m[1] = 200
m[2] = 300
p m[1], m[2]
p m[0, 3].encoding == Encoding::BINARY, m.to_s.encoding == Encoding::BINARY

q = m + 3
p q.size, (q - 3) == m, q == m, q.to_i == m.to_i + 3, (m <=> q), (q <=> m), (m <=> m)
p m == 5, m.eql?(m), m.to_i == m.to_int

w = Fiddle::Pointer.new(m.to_i)
p w.size, w[0, 2]
w.size = 4
p w.size
p Fiddle::Pointer.new(m.to_i, 8).size
p (Fiddle::Pointer.new(100) + 3).size, (Fiddle::Pointer.new(100) - 3).size

s = Fiddle::Pointer["hello"]
p s.to_s, s.size, Fiddle::Pointer.to_ptr("xyz").size, Fiddle::Pointer.to_ptr(0x10).to_i
p Fiddle::Pointer[s].equal?(s)
p Fiddle::Pointer.new(0).null?, Fiddle::NULL.null?, Fiddle::NULL.to_i
begin
  Fiddle::Pointer.new(0).to_s
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end
begin
  Fiddle::Pointer.new("abc")
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end

# what a bad access raises
n = Fiddle::Pointer.new(0)
[proc { n[0] }, proc { n[0, 4] }, proc { n[0] = 1 }, proc { n[0, 1] = "a" },
 proc { m[0] = "x" }, proc { m[0] = nil }, proc { m[0, 1] = nil }, proc { m[0, -1] },
 proc { m.to_s(-1) }, proc { m.size = "x" }, proc { m + "x" },
 proc { Fiddle::Pointer.new(1, "x") }, proc { Fiddle::Handle.new(5) }].each do |bad|
  begin
    bad.call
  rescue Fiddle::DLError, TypeError, ArgumentError => e
    puts "#{e.class}: #{e.message}"
  end
end
p n.to_str, m[1.5]

# a pointer to a pointer
cell = Fiddle::Pointer.malloc(8)
cell[0, 8] = (0..7).map { |i| (m.to_i >> (8 * i)) & 255 }.pack("C*")
p cell.ptr == m

# the free function
p Fiddle::Pointer.malloc(4).free
z = Fiddle::Pointer.malloc(4, Fiddle::RUBY_FREE)
p z.free.class, z.free.to_i == Fiddle::RUBY_FREE, z.freed?
z.call_free
p z.freed?
z.call_free
p z.freed?
y = Fiddle::Pointer.malloc(4)
y.free = Fiddle::RUBY_FREE
p y.free.class
y.call_free
p y.freed?
y2 = Fiddle::Pointer.new(Fiddle.malloc(4), 4, Fiddle::Function.new(Fiddle::RUBY_FREE, [Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOID))
p y2.free.class, y2.size

# memory freed when the pointer is collected: nothing to see, but nothing breaks
200.times { Fiddle::Pointer.malloc(64, Fiddle::RUBY_FREE)[0, 4] = "abcd" }
GC.start

a = Fiddle.malloc(8)
a = Fiddle.realloc(a, 64)
p a.class
Fiddle.free(a)
p Fiddle::SIZEOF_VOIDP, Fiddle::SIZEOF_INT, Fiddle::SIZEOF_LONG, Fiddle::SIZEOF_DOUBLE
