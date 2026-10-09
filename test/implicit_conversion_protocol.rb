# spinel: share
# CRuby's implicit conversion protocol at the builtin slots that take a path,
# a mode, an offset, or a write payload: a user object converts through
# #to_path / #to_str / #to_int / #to_s where the slot asks for it, instead of
# being refused at compile time.
require "pathname"
require "stringio"

dir = "/tmp/spinel_implicit_conversion_protocol_#{Process.pid}"
if Dir.exist?(dir)
  Dir.children(dir).each { |e| File.delete("#{dir}/#{e}") }
  Dir.rmdir(dir)
end
Dir.mkdir(dir)
file = "#{dir}/a.txt"
File.write(file, "abcdef\n")

# a #to_path the analysis cannot pin to String: CRuby checks the result
class Conf
  attr_accessor :path

  def to_path
    @path
  end
end

class PathLike
  def initialize(path)
    @path = path
  end

  def to_path
    @path
  end
end

# a class naming the path through #to_str is accepted too
class StrLike
  def initialize(path)
    @path = path
  end

  def to_str
    @path
  end
end

# #to_path wins over #to_str when both exist (rb_get_path's order)
class Both
  def initialize(path)
    @path = path
  end

  def to_path
    @path
  end

  def to_str
    "/nonexistent/#{@path}"
  end
end

pl = PathLike.new(file)
p File.exist?(pl)
p File.file?(pl)
p File.read(pl)
p File.basename(pl)
p File.dirname(pl) == dir
p File.extname(pl)
p File.expand_path(PathLike.new("x"), dir) == "#{dir}/x"
p File.size(pl)
p File.readlines(pl)
p File.readlines(pl, chomp: true)
p IO.read(pl)
p IO.readlines(pl)
lines = []
File.foreach(pl) { |l| lines << l }
p lines
p File.open(pl) { |f| f.read(3) }
p File.open(pl, "r") { |f| f.gets }
p File.join("a", PathLike.new("b"), "c")
p File.stat(pl).size
p File.exist?(StrLike.new(file))
p File.read(StrLike.new(file))
p File.exist?(Both.new(file))
conf = Conf.new
conf.path = file
p File.exist?(conf)
conf.path = nil
begin
  File.exist?(conf)
rescue TypeError => e
  p [e.class, e.message]
end
p File.atime(pl).class
p File.owned?(pl)
p File.realdirpath(PathLike.new("a.txt"), dl = PathLike.new(dir)) == File.realpath(file)
p File.expand_path("a.txt", PathLike.new(dir)) == file
p File.absolute_path("a.txt", PathLike.new(dir)) == file
p File.utime(Time.at(0), Time.at(0), pl)
p File.join(["a", PathLike.new("b")], "c")

p Dir.exist?(dl)
p Dir.entries(dl).sort
p Dir.children(dl)
p Dir.glob(PathLike.new("#{dir}/*.txt")).map { |f| File.basename(f) }
d = Dir.open(dl)
p d.path == dir
d.close
p Dir.empty?(dl)
sub = Pathname.new("#{dir}/sub")
p Dir.mkdir(sub)
p Dir.exist?(sub)
p Dir.rmdir(sub)

# Pathname is the everyday #to_path
pn = Pathname.new(file)
p File.exist?(pn)
p File.basename(pn)
p File.join(Pathname.new("a"), "b")
p IO.read(pn)

# through a boxed slot: the parameter's class is only known at run time,
# and #to_path still comes before #to_str there
def size_of(path)
  File.size(path)
end
p size_of(file)
p size_of(pl)
p size_of(pn)
p size_of(StrLike.new(file))
p size_of(Both.new(file))
p IO.sysopen(pl).class

# IO.copy_stream, IO#reopen, File.rename, File.symlink, File.delete
copy = "#{dir}/b.txt"
p IO.copy_stream(pl, PathLike.new(copy))
p File.read(copy)
io = File.open("/dev/null", "r")
p io.reopen(PathLike.new(copy), "r").read
io.close
moved = "#{dir}/c.txt"
p File.rename(PathLike.new(copy), PathLike.new(moved))
p File.exist?(moved)
link = "#{dir}/link"
p File.symlink(PathLike.new(moved), PathLike.new(link))
p File.readlink(PathLike.new(link)) == moved
p File.delete(PathLike.new(link), PathLike.new(moved))
p File.exist?(moved)

# a mode object: #to_int is asked first, as CRuby's mode parsing does
class ReadMode
  def to_int
    File::RDONLY
  end
end

class ModeName
  def to_str
    "r"
  end
end
p File.open(pl, ReadMode.new) { |f| f.read(2) }
p File.open(pl, ModeName.new) { |f| f.read(2) }
p File.open(pl, mode: ReadMode.new) { |f| f.read(2) }
class CreateMode
  def to_int
    File::WRONLY | File::CREAT
  end
end
made = "#{dir}/made.txt"
File.open(made, CreateMode.new, 0600) { |f| f.write("m") }
p format("%o", File.stat(made).mode & 0777)
File.delete(made)
# the permission bits reach open(2) behind a String mode too, positionally,
# as `perm:`, and behind `mode:`; a nil perm is the default; an exclusive
# mode still refuses an existing file
File.open(made, "w", 0600) { |f| f.write("m") }
p format("%o", File.stat(made).mode & 0777)
File.delete(made)
File.open(made, "w", perm: 0600) { |f| f.write("m") }
p format("%o", File.stat(made).mode & 0777)
File.delete(made)
File.open(made, mode: "w", perm: 0640) { |f| f.write("m") }
p format("%o", File.stat(made).mode & 0777)
File.delete(made)
File.open(made, File::WRONLY | File::CREAT, perm: 0600) { |f| p f.path == made }
p format("%o", File.stat(made).mode & 0777)
File.delete(made)
def maybe_perm(x)
  x ? 0600 : nil
end
File.open(made, "w", maybe_perm(false)) { |f| f.write("m") }
p format("%o", File.stat(made).mode & 0777)
File.open(made, "w", nil) { |f| p f.close_on_exec? }
begin
  File.open(made, "wx", 0600) { |f| f.write("!") }
rescue SystemCallError => e
  p e.class
end
p File.read(made)
File.delete(made)
begin
  File.open(made, "+", 0600)
rescue ArgumentError => e
  p e.message
end
begin
  File.open(made, "rx", 0600)
rescue ArgumentError => e
  p e.message
end
begin
  File.open(made, "ax")
rescue ArgumentError => e
  p e.message
end
File.open(made, "wx+", 0600) { |f| f.write("zz"); f.rewind; p f.read }
File.delete(made)

# the path is evaluated once even where the predicate stats it twice
class Counted
  def initialize(path)
    @path = path
    @calls = 0
  end

  attr_reader :calls

  def to_path
    @calls += 1
    @path
  end
end
counted = Counted.new(file)
p [File.file?(counted), counted.calls]

# a Time offset through #to_str
class Zone
  def to_str
    "+01:00"
  end
end
p Time.at(0).getlocal(Zone.new).utc_offset
p Time.at(0).localtime(Zone.new).utc_offset
t = Time.at(0)
t.localtime(Zone.new)
p t.utc_offset

# write payloads take #to_s, not #to_str
class Payload
  def to_s
    "payload"
  end
end
sio = StringIO.new
p sio.write(Payload.new)
p (sio << Payload.new).equal?(sio)
p sio.write(42)
p (sio << :sym).equal?(sio)
p sio.print(Payload.new, 1)
p sio.puts(Payload.new)
p sio.puts
result = sio.puts("assigned")
p result
class Nul
  def to_s
    "a\0b"
  end
end
p sio.print(Nul.new)
p sio.print(:sym, [1, 2])
class Plain
end
sio.puts(Plain.new)
p sio.string.sub(/0x[0-9a-f]+/, "0xADDR")
mixed = StringIO.new
[1, "a", :b].each { |x| mixed.puts(x) }
p mixed.string
File.open(file, "r+") { |f| p [f.pwrite(Payload.new, 1), File.read(file)] }
File.open(file, "w") { |f| p f.write_nonblock(Payload.new) }
p File.read(file)
p File.write(pl, Payload.new)
p File.write(pl, 42, mode: "a")
p File.write(pl, :sym, 2)
p File.read(file)
# the count answered is the count written, an embedded NUL included, whether
# the payload is a String statically or only at run time
def payload(nul)
  nul ? "a\0b" : Payload.new
end
p File.write(pl, payload(true))
p File.size(file)
p File.write(pl, payload(false))

# a #to_path that builds its answer is held across its siblings' conversions
class Fresh
  def initialize(n)
    @n = n
  end
  def to_path
    "seg" + @n.to_s
  end
end
bad = 0
2000.times do |i|
  r = File.join(Fresh.new(i), Fresh.new(i + 1), Fresh.new(i + 2))
  bad += 1 unless r == "seg#{i}/seg#{i + 1}/seg#{i + 2}"
end
p bad
# ...and across any call's other operands: the path's answer survives a
# payload's #to_s and a second path's #to_path, each of which allocates
class Churn
  def initialize(n)
    @n = n
  end
  def to_path
    2000.times { "z" * 40 }
    "#{DIR}/churn#{@n}.txt"
  end
end
class Loud
  def to_s
    2000.times { "z" * 40 }
    "PAY"
  end
end
DIR = dir
p File.write(Churn.new(1), Loud.new)
File.rename(Churn.new(1), Churn.new(2))
p [File.exist?("#{dir}/churn1.txt"), File.exist?("#{dir}/churn2.txt")]
p File.expand_path(Churn.new(1), Churn.new(2)) == "#{dir}/churn2.txt#{dir}/churn1.txt"
File.delete("#{dir}/churn2.txt")
# a single component is held through the join's own allocation, and an
# Array that contains itself is refused, not walked forever
class Built
  def to_path
    b = ""
    50.times { b = b + "ab" }
    b
  end
end
bad = 0
2000.times { bad += 1 unless File.join(Built.new) == "ab" * 50 }
p bad
loop_a = ["x"]
loop_a << loop_a
begin
  File.join(loop_a)
rescue ArgumentError => e
  p e.message
end

# the hold does not move a conversion: a call's other operands evaluate
# before any operand converts, each of IO#write's operands converts right
# before its own write, and a call with more operands than any hold size
# still holds them all
class Noisy
  def initialize(n)
    @n = n
  end
  def to_s
    $stdout.print("[c#{@n}]")
    "<#{@n}>"
  end
end
$stdout.write(Noisy.new(5), Noisy.new(6))
puts
def named
  puts "named"
  "#{DIR}/named.txt"
end
File.write(named, Payload.new)
File.write("#{dir}/churn1.txt", "x")
File.rename(Churn.new(1), named)
p [File.exist?("#{dir}/churn1.txt"), File.read("#{dir}/named.txt")]
File.delete("#{dir}/named.txt")
class Wide
  def initialize(s)
    @s = s
  end
  def to_path
    ("y" * 3000).sub("y", @s)[0, 3]
  end
end
letters = ("a".."t").to_a
bad = 0
100.times do
  r = File.join(Wide.new("a"), Wide.new("b"), Wide.new("c"), Wide.new("d"), Wide.new("e"),
                Wide.new("f"), Wide.new("g"), Wide.new("h"), Wide.new("i"), Wide.new("j"),
                Wide.new("k"), Wide.new("l"), Wide.new("m"), Wide.new("n"), Wide.new("o"),
                Wide.new("p"), Wide.new("q"), Wide.new("r"), Wide.new("s"), Wide.new("t"))
  bad += 1 unless r == letters.map { |x| x + "yy" }.join("/")
end
p bad

# the receiver and the argument still evaluate in order, once each
def trace(label, value)
  puts label
  value
end
def trace_io(label, io)
  puts label
  io
end
p File.exist?(trace("arg", pl))
p trace_io("recv", sio).write(trace("arg", Payload.new))
# ...and a converting operand that is a bare local converts only after the
# sibling it precedes has run: every argument first, then the conversions
class Announced
  def initialize(path)
    @path = path
  end
  def to_path
    puts "convert"
    @path
  end
end
def sideff(n)
  puts "sibling"
  n
end
announced = Announced.new(file)
p File.read(announced, sideff(4))
class Offset
  def to_int
    puts "convert"
    2
  end
end
off = Offset.new
p "abcdef"[off, sideff(3)]
class Spoken
  def to_s
    puts "convert"
    "payl"
  end
end
spoken = Spoken.new
File.open(file, "w") { |f| p f.write(spoken, sideff("Z")) }
p File.read(file)

File.delete(file)
Dir.rmdir(dir)
p Dir.exist?(dl)
