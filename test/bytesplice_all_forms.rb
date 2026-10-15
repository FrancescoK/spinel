buff = "abcdef".b
p buff.bytesplice(2, 0, "*********", 0, 3)
p buff, buff.encoding
s = +"hello"
p s.bytesplice(1, 2, "XYZW", 1, 2)
p s.bytesplice(0..1, "QRS", 1..2)
p s.bytesplice(1..-1, "ab")
p s.bytesplice(1.., "Z", ..0)
p s.bytesplice(-2, 5, "end", -1, 9)
u = +"héllo"
[[2, 1], [1, 1], [1, 2], [0, 9], [6, 0], [7, 0], [-9, 1]].each do |b, l|
  begin; p u.dup.bytesplice(b, l, "x"); rescue IndexError => e; p [e.class, e.message]; end
end
begin; p u.dup.bytesplice(0, 1, "é", 1, 1); rescue IndexError => e; p [e.class, e.message]; end
begin; p u.dup.bytesplice(9..10, "x"); rescue RangeError => e; p [e.class, e.message]; end
begin; p u.dup.bytesplice(0, 1, "abc", 4, 1); rescue IndexError => e; p [e.class, e.message]; end
begin; p u.dup.bytesplice(0, -1, "abc"); rescue IndexError => e; p [e.class, e.message]; end
m = "ab".b
p m.bytesplice(0, 1, "é"), m.encoding
w = +"ab"
p w.bytesplice(0, 1, "\xff".b), w.encoding
t = "x".freeze
begin; t.bytesplice(0, 1, "y"); rescue => e; p e.class; end
def mk2(x) = x
ps = mk2([+"hello", 1][ARGV.size])
p ps.bytesplice(1, 2, "XYZW", 1, 2)
p ps.bytesplice(0..1, "QRS", 1..2)
p ps.bytesplice(1..-1, "ab")
p ps.bytesplice(0, 1, "!!")
p ps
p "\x80abc".dup.bytesplice(0, 1, "x")
begin; s = "é".dup; s.bytesplice(0, 2, "a\xff".b, 0, 1); p s, s.encoding; rescue => e; p e.class, e.message; end
begin; p "é".dup.bytesplice(0, 2, "\xff".b); rescue => e; p e.class, e.message; end
begin; p "\xff".b.bytesplice(0, 1, "é"); rescue => e; p e.class, e.message; end
begin; "abc".dup.bytesplice(10..11, "x", 20..21); rescue => e; p e.class, e.message; end
class KB; def initialize; @s = +"abc"; end; def go; @s.bytesplice(0, 1, "\xff".b); @s; end; end
kx = KB.new.go; p kx.encoding, kx
def mk3(x) = x
y = mk3([+"abc", 1][ARGV.size]); y.bytesplice(0, 1, "\xff".b); p y.encoding
z = mk3(["ab\xff".b, 1][ARGV.size]); z.bytesplice(0, 1, "x"); p z.encoding
p "ab".b.bytesplice(0, 1, "é").encoding
p "abc".dup.bytesplice(0, 1, 2..3) rescue p $!
p "hello".dup.bytesplice(..1, "Q"), "hello".dup.bytesplice(3.., "Q"), "hello".dup.bytesplice(0...-10, "!")
begin; "hello".dup.bytesplice(0..1, 2, "abc", 0, 1); rescue => e; p e.class, e.message; end
begin; "hello".dup.bytesplice(0, 1, "abc", 0..1, 1); rescue => e; p e.class, e.message; end
begin; "abc".dup.bytesplice(9..10, 1); rescue => e; p e.class, e.message; end
bn = mk3(["ab".b, 1][ARGV.size]); bn.bytesplice(0, 1, "é", 0, 2); p bn, bn.encoding == Encoding::UTF_8
br = mk3(["ab".b, 1][ARGV.size]); br.bytesplice(0..0, "é"); p br, br.encoding == Encoding::UTF_8
class BSToStr; def to_str; puts "to_str"; "zz"; end; end
begin; "abc".dup.bytesplice(9..10, BSToStr.new); rescue => e; p e.class, e.message; end
p "abc".dup.bytesplice(0..1, BSToStr.new)
begin; "abc".dup.bytesplice(9..10, [1]); rescue => e; p e.class, e.message; end
begin; "hello".dup.bytesplice(1.0, 2, "x"); rescue => e; p e.class, e.message; end
begin; "hello".dup.bytesplice(1..-Float::INFINITY, "x"); rescue => e; p e.class, e.message; end
p "hello".dup.bytesplice(1..2.5, "x")
