require "tmpdir"

def ev(o, m, *a, **k) = o.send(m, *a, **k)
def pub(o, m, *a, **k) = o.public_send(m, *a, **k)
def lines_of(s, **k) = s.lines(**k)

h = {chomp: true}
p "a\nb\n".lines(**h)
p lines_of("a\nb\n", chomp: true)
p lines_of("a\nb\n")
r = []
"a\nb\n".each_line(**h) { |l| r << l }
p r
flag = [true, 1][0]
r = []
"a\nb\n".each_line(chomp: flag) { |l| r << l }
p r
p ev("a\nb\n", :lines, chomp: true)
p pub("a\nb\n", :lines, chomp: true)
p ev([1, "a\nb\n"][1], :lines, chomp: true)

o = {offset: 1}
p "\x01\x02\x03".unpack1("C", **o)
p "\x01\x02\x03".unpack("C*", **o)
p ev("\x01\x02\x03", :unpack1, "C", offset: 1)
p pub("\x01\x02\x03", :unpack1, "C", offset: 2)

class K
  attr_accessor :v
end
k = K.new
k.v = 1
f = {freeze: true}
p (+"a").clone(**f).frozen?
c = k.clone(**f)
p c.frozen?, c.v
[nil, true, false].each { |fz| p (+"a").clone(freeze: fz).frozen?, "a".freeze.clone(freeze: fz).frozen? }
p ev(+"a", :clone, freeze: true).frozen?
p ev(k, :clone, freeze: true).frozen?
p ev([1, "a"][1], :clone, freeze: false).frozen?
bad = [1, "x"][0]
begin
  (+"a").clone(freeze: bad)
rescue ArgumentError => e
  p e.message
end

path = File.join(Dir.tmpdir, "builtin_kwarg_honored_#{$$}.txt")
File.write(path, "x\ny\n")
r = []
File.open(path) { |io| io.each_line(**h) { |l| r << l } }
p r
p File.open(path) { |io| io.readlines(**h) }
File.delete(path)

class ToHashOpts
  def to_hash = {chomp: true}
end
nk = nil
p "a\nb\n".lines(**nk)
p "a\nb\n".lines(**ToHashOpts.new)
def fwd_lines(s, **k) = s.lines(**k)
[{chomp: true, foo: 1}, {foo: 1, bar: 2}].each do |bad|
  fwd_lines("a\n", **bad)
rescue ArgumentError => e
  p e.message
end
begin
  "ab".unpack1("C", **{offset: 1, x: 2})
rescue ArgumentError => e
  p e.message
end
flag = false
src = +"x"
p (flag = true; src).clone(freeze: flag).frozen?
