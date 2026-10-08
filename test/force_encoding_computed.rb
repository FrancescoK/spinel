# force_encoding with an Encoding or a name that is no literal (a local, a
# default parameter) retags the String. It used to leave the tag alone, so
# a binary String asked for UTF-8 through a parameter stayed binary.

def retag(s, enc = Encoding::UTF_8)
  s.force_encoding(enc)
end

p retag("é".b).encoding, retag("é".b).size
p retag(+"é", Encoding::BINARY).encoding, retag(+"é", Encoding::BINARY).size
name = "binary"
p (+"é").force_encoding(name).encoding
name = "utf-8"
p "é".b.force_encoding(name).encoding
e = Encoding::ASCII_8BIT
p "abc".dup.force_encoding(e).encoding

# a shared handle (#6179) keeps the tag across appends
pr = proc { |t| t << "!" }
h = +"héllo"
pr.call(h)
h.force_encoding(e)
h << "y" * 300
p h.encoding, h.size
h.force_encoding(retag("x".b).encoding)
p h.encoding, h.size

# bad arguments raise as CRuby's do, a frozen String first
[nil, 1, "nope"].each do |bad|
  begin
    (+"x").force_encoding(bad)
  rescue TypeError, ArgumentError => ex
    puts "#{ex.class}: #{ex.message}"
  end
end
begin
  "x".freeze.force_encoding(e)
rescue FrozenError => ex
  puts ex.class
end
