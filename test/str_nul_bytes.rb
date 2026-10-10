require "tmpdir"

def bx(v) = [v, 1][0]

def str(t, v)
  puts "#{t}: #{v.inspect} #{v.bytes.inspect} #{v.length}"
end

def strs(t, v)
  puts "#{t}: #{v.inspect} #{v.map(&:bytes).inspect} #{v.length}"
end

str "delete_prefix", "a\0b".delete_prefix("a")
str "delete_prefix nul", "a\0b".delete_prefix("a\0")
str "delete_prefix miss", "a\0b".delete_prefix("x")
puts "start_with? #{"a\0b".start_with?("a\0c")} #{"a\0c".start_with?("a\0c")} #{"ab".start_with?("abc")} #{"ab".start_with?("")}"
str "upcase ascii", "\0\0xa".upcase(:ascii)
str "downcase ascii", "\0\0XA".downcase(:ascii)
str "swapcase ascii", "\0\0xA".swapcase(:ascii)
str "capitalize ascii", "\0\0xa".capitalize(:ascii)
str "upcase ascii bin", "\0\xffxa".b.upcase(:ascii)
str "chomp nul", "xa\0".chomp("\0")
str "chomp paragraph", "xa\n\n".chomp("")
strs "lines nul", "\0\0xa".lines("\0")
strs "lines nul chomp", "a\0b\0".lines("\0", chomp: true)
strs "each_line nul", "a\0b\0c".each_line("\0").to_a
strs "lines paragraph", "a\n\n\nb\nc\n\n".lines("")
strs "lines bin", "\0\xff\0x".b.lines("\0")
strs "split limit nul", "\0\0xa".split("\0", 2)
strs "split limit a", "\0\0xa".split("a", 2)
strs "split limit empty", "a\0bc".split("", 3)
strs "split limit plain", "a,b,c".split(",", 2)
strs "scan nul", "\0\0xa".scan("\0")
strs "scan a", "\0\0xa".scan("a")
strs "scan empty", "a\0b".scan("")
"\0a\0a".scan("a") { |m| print $~.begin(0), "," }
puts
str "tr_s", "aa\0\0bb\0c".tr_s("a\0", "xy")
str "tr_s utf8", "héllo  wörld".tr_s("lo", "*")
str "tr_s bin", "\xff\xffab".b.tr_s("\xff".b, "z")
str "tr_s bin to", "aab".b.tr_s("a", "\xfe".b)
str "tr_s bin byte", "\xc3\xa9\xc3\xa9".b.tr_s("\xc3".b, "x")
str "tr bin byte", "\xc3\xa9\xc3\xa9".b.tr("\xc3".b, "x")
str "sub amp", "xyz".sub("y", "a\0\\&")
str "gsub amp", "xyz".gsub("y", "\\&\0b")
str "gsub nul match", "x\0z".gsub("\0", "[\\&]")
str "scrub nul", "a\xffb".scrub("\0")
H = { "\0" => "N", "b" => "B\0" }
str "sub hash nul", "a\0b\0".sub("\0", H)
str "sub hash", "a\0b\0b".sub("b", H)
str "gsub hash", "a\0b\0b".gsub("b", H)
str "gsub hash empty", "a\0b".gsub("", H)
str "re gsub hash", "a\0b\0b".gsub(/b/, H)
str "re gsub hash nul key", "a\0b\0b".gsub(/\0/, H)
str "re sub hash", "\0\0b".sub(/b/, H)
str "encode replace nul", "a\xffb".b.encode("UTF-8", invalid: :replace, undef: :replace, replace: "\0")

str "boxed delete_prefix", bx("a\0b").delete_prefix(bx("a\0"))
puts "boxed start_with? #{bx("a\0b").start_with?(bx("a\0c"))}"
str "boxed upcase ascii", bx("\0\0xa").upcase(:ascii)
str "boxed chomp nul", bx("xa\0").chomp(bx("\0"))
strs "boxed lines nul", bx("\0\0xa").lines("\0")
strs "boxed split limit", bx("\0\0xa").split(bx("a"), 2)
strs "boxed scan", bx("\0\0xa").scan(bx("a"))
str "boxed tr_s", bx("aa\0\0bb\0c").tr_s("a\0", "xy")
str "boxed tr_s bin", bx("\xc3\xa9\xc3\xa9".b).tr_s("\xc3".b, "x")
str "boxed sub amp", bx("xyz").sub("y", "a\0\\&")
str "boxed scrub nul", bx("a\xffb").scrub("\0")
path = File.join(Dir.tmpdir, "spinel_str_nul_bytes_#{Process.pid}.txt")
File.write(path, "x\0y\0z")
File.open(path) { |f| str "gets nul", f.gets("\0"); str "gets nul 2", f.gets("\0") }
strs "readlines nul", File.readlines(path, "\0")
strs "readlines nul chomp", File.readlines(path, "\0", chomp: true)
File.delete(path)
