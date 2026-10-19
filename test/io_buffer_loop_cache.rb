# A loop whose IO::Buffer reads are literal-typed get_values keeps the bytes
# they see and their count in locals (the header cache), and reads there.
# Every read outside them takes the out-of-line path with its CRuby error:
# each type over every kind of buffer, read past both ends. Anything that
# could free, resize or transfer the buffer is a call, which leaves the loop
# uncached; a trap handler doing it runs at the loop's poll, after which the
# cache is read again. The 32-bit integer types, whose values pass 2^31,
# are io_buffer_loop_cache_int32.rb.
require "tmpdir"

def fill(b)
  i = 0
  while i < b.size
    b.set_value(:U8, i, (i * 73 + 129) % 256)
    i += 1
  end
  b
end

# one cached loop per type, from `from` up to `to`, summing what it reads
def scan(t, b, from, to)
  s = 0
  i = from
  case t
  when :U8  then while i < to; s += b.get_value(:U8, i); i += 1; end
  when :S8  then while i < to; s += b.get_value(:S8, i); i += 1; end
  when :u16 then while i < to; s += b.get_value(:u16, i); i += 1; end
  when :s16 then while i < to; s += b.get_value(:s16, i); i += 1; end
  when :U16 then while i < to; s += b.get_value(:U16, i); i += 1; end
  when :S16 then while i < to; s += b.get_value(:S16, i); i += 1; end
  end
  "#{s}"
rescue => e
  "#{s} then at #{i}: #{e.class}: #{e.message}"
end
def scanf(t, b, from, to)
  s = 0.0
  i = from
  case t
  when :f32 then while i < to; s += b.get_value(:f32, i); i += 1; end
  when :f64 then while i < to; s += b.get_value(:f64, i); i += 1; end
  when :F32 then while i < to; s += b.get_value(:F32, i); i += 1; end
  when :F64 then while i < to; s += b.get_value(:F64, i); i += 1; end
  end
  "#{s}"
rescue => e
  "#{s} then at #{i}: #{e.class}: #{e.message}"
end
def run(t, label, b)
  n = b ? b.size : 3
  [[0, n], [-1, n], [0, n + 1]].each do |from, to|
    r = [:f32, :f64, :F32, :F64].include?(t) ? scanf(t, b, from, to) : scan(t, b, from, to)
    puts "#{t} #{label} #{from}...#{to}: #{r}"
  end
end

path = File.join(Dir.tmpdir, "sp_iob_loop_cache_#{Process.pid}.bin")
File.binwrite(path, (0...16).map { |i| ((i * 73 + 129) % 256).chr }.join)

[:U8, :S8, :u16, :s16, :U16, :S16, :f32, :f64, :F32, :F64].each do |t|
  w = IO::Buffer.size_of(t)
  b = fill(IO::Buffer.new(16))
  run(t, "owned", b)
  run(t, "slice", b.slice(3, 9))
  run(t, "zero", IO::Buffer.new(0))
  run(t, "short", fill(IO::Buffer.new(w - 1)))
  f = fill(IO::Buffer.new(16))
  fs = f.slice(0, 8)
  f.free
  run(t, "freed", f)
  run(t, "slice-of-freed", fs)
  tr = fill(IO::Buffer.new(16))
  u = tr.transfer
  run(t, "transferred-from", tr)
  run(t, "transferred-to", u)
  r = fill(IO::Buffer.new(16))
  rs = r.slice(8, 8)
  r.resize(4)
  run(t, "slice-of-shrunk", rs)
  run(t, "shrunk", r)
  File.open(path) do |io|
    run(t, "mapped", IO::Buffer.map(io, nil, 0, IO::Buffer::READONLY))
  end
  run(t, "for", IO::Buffer.for("ABCDEFGHIJ"))
end
File.delete(path)

# a receiver that may be nil
def maybe(b)
  s = 0
  i = 0
  while i < 4
    s += b.get_value(:U8, i)
    i += 1
  end
  "#{s}"
rescue => e
  "#{s} then at #{i}: #{e.class}"
end
puts "nil: #{maybe(ARGV.size > 5 ? fill(IO::Buffer.new(4)) : nil)} #{maybe(fill(IO::Buffer.new(4)))}"

# bounded by the buffer's own size, which does not put a byte at i: a nil,
# a freed buffer and an invalidated slice (which still answers its size)
# answer as uncached -- the test raises, ends, or the read does, after the
# statement ahead of it has run.
def bounded(b)
  n = 0
  s = 0
  i = 0
  while i < b.size
    n += 1
    s += b.get_value(:U8, i) - b.get_value(:S8, i)
    i += 1
  end
  s
rescue => e
  "#{n} #{s} then at #{i}: #{e.class}: #{e.message}"
end
# ...but a wider read at i, or a byte past it, still tests its end
def bounded_wide(b)
  s = 0
  i = 0
  while i < b.size
    s += b.get_value(:u16, i)
    i += 1
  end
  s
rescue => e
  "#{s} then at #{i}: #{e.class}: #{e.message}"
end
def bounded_next(b)
  s = 0
  i = 0
  while i < b.size
    s += b.get_value(:U8, i + 1)
    i += 1
  end
  s
rescue => e
  "#{s} then at #{i}: #{e.class}: #{e.message}"
end
def show_bounded(b) = puts "bounded #{b.size}: #{bounded(b)} #{bounded_wide(b)} #{bounded_next(b)}"
show_bounded(fill(IO::Buffer.new(16)))
show_bounded(fill(IO::Buffer.new(16)).slice(5, 7))
show_bounded(IO::Buffer.new(0))
show_bounded(IO::Buffer.for("xyz"))
fb = fill(IO::Buffer.new(16))
fb.free
show_bounded(fb)
src = fill(IO::Buffer.new(16))
gone = src.slice(4, 8)
src.free
show_bounded(gone)
src = fill(IO::Buffer.new(16))
cut = src.slice(4, 8)
src.resize(6)
show_bounded(cut)
puts "bounded nil: #{bounded(ARGV.size > 5 ? fill(IO::Buffer.new(4)) : nil)}"

# free / resize / transfer inside the loop: a call, so the loop is not
# cached, and the read after it raises as in CRuby
def inside(op)
  b = fill(IO::Buffer.new(8))
  s = 0
  i = 0
  while i < 8
    s += b.get_value(:U8, i)
    case op
    when :free then b.free if i == 2
    when :resize then b.resize(4) if i == 2
    when :transfer then b.transfer if i == 2
    when :grow then b.resize(32) if i == 2
    end
    i += 1
  end
  "#{s}"
rescue => e
  "#{s} then at #{i}: #{e.class}: #{e.message}"
end
[:free, :resize, :transfer, :grow].each { |op| puts "inside #{op}: #{inside(op)}" }

# between two cached loops over the same buffer, through an ivar and an
# attribute read
class Holder
  attr_reader :buf
  def initialize(b) = @buf = b
  def sum
    s = 0
    i = 0
    while i < 8
      s += @buf.get_value(:U8, i)
      i += 1
    end
    s
  rescue => e
    "#{s} then at #{i}: #{e.class}: #{e.message}"
  end
  def self.sum(h)
    s = 0
    i = 0
    while i < 8
      s += h.buf.get_value(:U8, i)
      i += 1
    end
    s
  rescue => e
    "#{s} then at #{i}: #{e.class}: #{e.message}"
  end
end
h = Holder.new(fill(IO::Buffer.new(8)))
puts "holder: #{h.sum} #{Holder.sum(h)}"
h.buf.resize(4)
puts "holder resized: #{h.sum} #{Holder.sum(h)}"
h.buf.resize(8)
puts "holder regrown: #{h.sum} #{Holder.sum(h)}"
h.buf.transfer
puts "holder transferred: #{h.sum} #{Holder.sum(h)}"

# a trap handler frees, shrinks or transfers the buffer the loop reads
# through another name; it runs at the loop's poll, and the read after it
# raises as in CRuby
def spin(b)
  s = 0
  i = 0
  while i < 2_000_000_000
    s += b.get_value(:U8, i & 7)
    i += 1
  end
  "no signal"
rescue => e
  "#{e.class}: #{e.message.sub(/offset=\d+/, "offset=N")}"
end
pid = Process.pid
[:free, :resize, :transfer, :slice].each do |op|
  $buf = fill(IO::Buffer.new(8))
  b = op == :slice ? $buf.slice(0, 8) : $buf
  Signal.trap(:USR1) do
    case op
    when :free, :slice then $buf.free
    when :resize then $buf.resize(1)
    when :transfer then $keep = $buf.transfer
    end
  end
  kicker = Process.spawn("sh", "-c", "sleep 0.2; kill -USR1 #{pid}")
  puts "trap #{op}: #{spin(b)}"
  Process.wait(kicker)
end
