# encode and encode! read their arguments as CRuby does: an encoding that is
# no Encoding and no String is a TypeError, a name no encoding has is
# Encoding::ConverterNotFoundError, a bad option value raises; broken UTF-8
# is invalid where a character the destination lacks is undefined; US-ASCII
# holds ASCII only; and encode! transcodes as encode does, where it once only
# retagged the receiver.
class Named
  def initialize(n) = @n = n
  def to_str = @n
end
class Plain; end

def box(v) = [v, 1][0]

def show(label)
  r = yield
  puts "#{label}: #{r.inspect}#{" #{r.encoding}" if r.is_a?(String)}"
rescue TypeError, ArgumentError, EncodingError, FrozenError => e
  puts "#{label}: #{e.class}: #{e.message}"
end

["x", "héllo"].each do |s|
  [1, :a, [1], nil, true, 2.5, Plain.new].each do |bad|
    show("dst #{bad.class}") { s.encode(bad) }
    show("src #{bad.class}") { s.encode("UTF-8", bad) }
    show("boxed dst #{bad.class}") { box(s).encode(box(bad)) }
  end
  show("unknown dst") { s.encode("l") }
  show("unknown src") { s.encode("UTF-8", "l") }
  show("unknown both") { s.encode("l", "o") }
  show("same unknown") { s.encode("l", "L") }
  show("utf8") { s.encode("utf8") }
  show("external") { s.encode("external") }
  show("Encoding, unknown src") { s.encode(Encoding::UTF_8, "l") }
  show("to_str dst") { s.encode(Named.new("BINARY")) }
  show("to_str unknown") { s.encode(Named.new("l")) }
  show("boxed unknown") { box(s).encode(box("l")) }
  show("invalid: :x") { s.encode("UTF-8", invalid: :x) }
  show("undef: 1") { s.encode("BINARY", undef: 1) }
  show("replace: 1") { s.encode("BINARY", undef: :replace, replace: 1) }
  show("utf-8 as utf-8") { s.b.encode("UTF-8", "UTF-8") }
  show("binary as binary") { s.encode("BINARY", "BINARY") }
end
show("options only, binary") { "\xff".b.encode(invalid: :replace) }
show("options only, UTF-8") { "h\xffllo".encode(invalid: :replace) }

# encode!: the receiver changes as encode's answer; one that keeps its bytes
# is retagged where it is, which every name for it sees
s = +"héllo"
show("encode! non-ASCII to binary") { s.encode!("BINARY") }
p [s, s.encoding.to_s]
s = +"hello"
r = s.encode!("BINARY")
p [r.equal?(s), s, s.encoding.to_s]
s = "\xff".b
show("encode! binary byte to UTF-8") { s.encode!("UTF-8") }
p [s, s.encoding.to_s]
s = "\xc3\xa9".b
s.encode!("UTF-8", "UTF-8")
p [s, s.encoding.to_s]
s = +"x"
[1, :a, nil, Plain.new].each { |bad| show("encode! #{bad.class}") { s.encode!(bad) } }
show("encode! unknown") { s.encode!("l") }
show("encode! unknown src") { s.encode!("UTF-8", "l") }
show("encode! frozen, bad argument") { "x".freeze.encode!(1) }
show("encode! frozen") { "x".freeze.encode!("UTF-8") }

b = box(+"héllo")
show("boxed encode! non-ASCII") { b.encode!("BINARY") }
show("boxed encode! bad") { b.encode!(1) }
b = box(+"hello")
b.encode!("BINARY")
show("boxed encode! retagged") { b }

# a user method of the same name beside the builtin
class U; def encode(*) = :u; end
[box("x"), U.new].each do |o|
  [1, "l", nil].each { |bad| show("beside a user encode #{bad.inspect}") { o.encode(bad) } }
end


# encode! retags the one String every name for it holds
class Holder
  attr_reader :s
  def initialize = @s = +"hello"
  def run = @s.encode!("BINARY")
end
o = Holder.new
t = o.s
o.run
p [o.s.encoding.to_s, t.encoding.to_s]
a = +"hello"
b = a
a.encode!("BINARY")
p [a.encoding.to_s, b.encoding.to_s]
h = { k: +"abc" }
h[:k].encode!("BINARY")
p h[:k].encoding.to_s

def bytes(label)
  puts "#{label}: #{yield.inspect}"
rescue TypeError, ArgumentError, EncodingError => e
  puts "#{label}: #{e.class}: #{e.message}"
end

# US-ASCII holds ASCII only (and is UTF-8 here): a byte >= 0x80 read as
# US-ASCII is invalid, a non-ASCII character has no place in it
bytes("US-ASCII source") { "h\xC3llo".encode("UTF-8", "US-ASCII") }
bytes("US-ASCII source, replaced") { "h\xC3llo".encode("UTF-8", "US-ASCII", invalid: :replace) }
bytes("US-ASCII source to binary") { "h\xC3llo".encode("BINARY", "US-ASCII") }
bytes("US-ASCII source to binary, replaced") { "h\xC3llo".encode("BINARY", "US-ASCII", invalid: :replace) }
bytes("US-ASCII to itself, replaced") { "h\xC3llo".encode("US-ASCII", "US-ASCII", invalid: :replace) }
bytes("US-ASCII to itself, *") { "h\xC3llo".encode("US-ASCII", "US-ASCII", invalid: :replace, replace: "*") }
bytes("to US-ASCII") { "héllo".encode("US-ASCII") }
bytes("to US-ASCII, replaced") { "héllo".encode("US-ASCII", undef: :replace) }
bytes("to US-ASCII, *") { "héllo".encode("US-ASCII", undef: :replace, replace: "*") }
bytes("binary to US-ASCII") { "h\xFFllo".b.encode("US-ASCII") }
bytes("binary to US-ASCII, replaced") { "h\xFFllo".b.encode("US-ASCII", undef: :replace) }
bytes("ASCII to US-ASCII") { "hello".encode("ascii") }

# broken UTF-8 is invalid, named as CRuby names it, not undefined
["h\xC3llo", "h\xFFllo", "h\xE3\x81", "h\xE3\x81llo", "\xC3\"", "\xC3\n", "\xED\xA0\x80", "é\xFF"].each_with_index do |s, i|
  ["BINARY", "US-ASCII"].each do |d|
    bytes("broken #{i} to #{d}") { s.encode(d) }
    bytes("broken #{i} to #{d}, invalid replaced") { s.encode(d, invalid: :replace) }
    bytes("broken #{i} to #{d}, undef replaced") { s.encode(d, undef: :replace) }
    bytes("broken #{i} to #{d}, both") { s.encode(d, invalid: :replace, undef: :replace, replace: "*") }
  end
end

# the replacement: broken UTF-8 raises whether or not it is put in; one the
# destination cannot hold raises when it is
bytes("broken replacement") { "hello".encode("BINARY", undef: :replace, replace: "\xFF") }
bytes("broken replacement, same encoding") { "hello".encode("UTF-8", replace: "\xFF") }
bytes("é into binary, not put in") { "hello".encode("BINARY", undef: :replace, replace: "é") }
bytes("é into binary") { "héllo".encode("BINARY", undef: :replace, replace: "é") }
bytes("é into UTF-8") { "h\xFFllo".b.encode("UTF-8", undef: :replace, replace: "é") }
bytes("binary byte into UTF-8") { "h\xFFllo".b.encode("UTF-8", undef: :replace, replace: "\xFF".b) }
bytes("ASCII binary into UTF-8") { "h\xFFllo".b.encode("UTF-8", undef: :replace, replace: "ab".b) }
# (the class alone: how CRuby names the binary encoding here varies by version)
begin
  "h\xFFllo".encode("UTF-8", invalid: :replace, replace: "é".b)
rescue Encoding::CompatibilityError => e
  puts "binary é scrubbing UTF-8: #{e.class}"
end
bytes("binary é, nothing to scrub") { "hllo".encode("UTF-8", invalid: :replace, replace: "é".b) }
begin
  "h\xC3llo".encode("US-ASCII", "US-ASCII", invalid: :replace, replace: "é")
rescue Encoding::CompatibilityError => e
  puts "é scrubbing US-ASCII: #{e.class}"
end
bytes("empty replacement") { "héllo".encode("BINARY", undef: :replace, replace: "") }
begin
  "hello".encode("US-ASCII", "US-ASCII", invalid: :replace, replace: "☃")
rescue Encoding::CompatibilityError => e
  puts "☃ scrubbing clean US-ASCII: #{e.class}"
end

# a replace: alone replaces undefined characters, not invalid ones
bytes("replace: alone") { "héllo".encode("BINARY", replace: "*") }
bytes("replace: alone, broken byte") { "h\xFFllo".encode("BINARY", replace: "*") }
bytes("replace: alone, from binary") { "h\xFFllo".b.encode("UTF-8", replace: "*") }
bytes("replace: alone, same encoding") { "h\xFFllo".encode("UTF-8", replace: "*") }
bytes("replace: with invalid:") { "héllo".encode("BINARY", invalid: :replace, replace: "*") }

# a replacement the destination cannot hold raises before the conversion
# starts, unless the String is ASCII, which converts without one
bytes("replacement converted first") { "h\xFFé".encode("BINARY", replace: "☃") }
bytes("replacement converted first, broken") { "h\xFFllo".encode("US-ASCII", invalid: :replace, replace: "☃") }
bytes("replacement on ASCII text") { "hello".encode("BINARY", replace: "☃") }
bytes("binary replacement on ASCII text") { "hello".encode("UTF-8", "BINARY", replace: "\xFF".b) }

# the options are read before the encodings
bytes("bad invalid, bad encoding") { "x".encode(1, invalid: :x) }
bytes("bad undef, unknown encoding") { "x".encode("l", undef: 1) }
bytes("bad replace, bad encoding") { "x".encode(1, replace: 1) }

# every argument runs, in source order; a key encode does not know is
# ignored; a third positional is an ArgumentError once they have run
def note(v) = (puts "ran #{v.inspect}"; v)
bytes("order") { "héllo".encode(note("BINARY"), replace: note("*"), undef: note(:replace), bogus: note(1)) }
bytes("String key") { "héllo".encode("BINARY", "undef" => :replace) }
bytes("three positionals") { "x".encode(note("UTF-8"), "UTF-8", note("x")) }
bytes("Hash positional") { "x".encode("UTF-8", { invalid: :replace }) }
h = { a: +"x" }
bytes("three positionals on a Hash value") { h[:a].encode("UTF-8", "UTF-8", note("x")) }
boxed = [+"y", 1][0]
bytes("three positionals, boxed") { boxed.encode("UTF-8", "UTF-8", note("x")) }

# the String converted is the receiver's once the arguments have run: one
# an argument appends to, not one an argument puts in its place
s = +"hello"
bytes("argument appends to the receiver") { s.encode((s << "x"; "BINARY")) }
v = +"abc"
bytes("argument rebinds the receiver") { v.encode((v = +"zzz"; "BINARY")) }
p v
@w = +"hi"
bytes("argument appends to an ivar receiver") { @w.encode((@w << "!"; "BINARY")) }
u = +"hello"
u.encode!((u << "x"; "BINARY"))
p [u, u.encoding.to_s]

# an encoding spinel does not have: ASCII between two encodings that hold it
# as ASCII is the bytes
bytes("ASCII to ISO-8859-1") { "hello".encode("ISO-8859-1") }
show("ASCII from ISO-8859-1") { "hello".b.encode("UTF-8", "ISO-8859-1") }
bytes("ASCII binary to Shift_JIS") { "hello".b.encode("Shift_JIS") }
# and an empty String has no bytes in any encoding
bytes("empty to UTF-32LE") { "".encode("UTF-32LE") }
bytes("empty from UTF-16BE") { "".encode("UTF-8", "UTF-16BE") }

# a `**` operand's options are read at run time, each source binding over
# the ones before it, as a dynamic send forwards them
opts = { undef: :replace, replace: "*" }
bytes("** options") { "héllo".encode("BINARY", **opts) }
bytes("literal after **") { "héllo".encode("BINARY", **opts, replace: "#") }
bytes("** after literal") { "héllo".encode("BINARY", replace: "#", **opts) }
bytes("** String key") { "héllo".encode("BINARY", **{ "undef" => :replace }) }
bytes("** bad invalid") { "x".encode("UTF-8", **{ invalid: :x }) }
def ev(o, m, *a, **) = o.send(m, *a, **)
bytes("send encode") { ev(+"héllo", :encode, "BINARY", undef: :replace) }
bytes("send encode, source") { ev(+"h\xFFllo".b, :encode, "UTF-8", "BINARY", undef: :replace, replace: "?") }
bytes("send encode!, retag") { ev(+"hello", :encode!, "BINARY", undef: :replace) }

# a splat's count is the run time's
args = ["BINARY"]
bytes("splat") { "héllo".encode(*args, undef: :replace) }
two = ["UTF-8", "BINARY"]
bytes("splat of two") { "h\xFFllo".b.encode(*two, undef: :replace, replace: "?") }
bytes("splat of three") { "x".encode(*["UTF-8", "UTF-8", "x"]) }
bytes("empty splat") { "héllo".encode(*[]) }
bytes("splat, then a positional") { "h\xFFllo".b.encode(*["UTF-8"], "BINARY", undef: :replace) }
bytes("splat of nil") { "hello".encode(*nil) }
