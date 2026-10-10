# spinel: share
# A String mutator whose receiver is itself a call runs that call once. The
# append_as_bytes and bytesplice arms read the receiver again for the
# mutability check, the mutation and the write-back, so a receiver that was
# a mutator (`s.concat("x", "y").append_as_bytes("z")`) ran twice and its
# argument went in twice; and a chain of those never reached the variable.
s = String.new("ab")
p s.concat("x", "y").append_as_bytes("z"), s
s = String.new("ab")
p((s << "x").append_as_bytes("z"), s)
s = String.new("ab")
p s.prepend("x", "y").append_as_bytes("z"), s
s = String.new("ab")
p s.insert(1, "-").append_as_bytes("z", 65), s
s = String.new("ab")
p s.replace("qq").append_as_bytes("z"), s
s = String.new("abcdef")
p s.concat("1", "2").bytesplice(0, 2, "Q"), s
s = String.new("abcdef")
p((s << "1").bytesplice(0..1, "Q"), s)
s = String.new("abcdef")
p s.prepend("x", "y").bytesplice(0..0, "Q"), s
s = String.new("abcd")
p s.upcase!.bytesplice(0, 1, "x"), s
s = String.new("abcd")
p s.chomp!("d").append_as_bytes("!"), s
# the chain's later links reach the variable too
s = String.new("ab")
s.concat("x", "y").append_as_bytes("z").append_as_bytes("w")
p s
s = String.new("abcdef")
s.concat("1").bytesplice(0, 1, "Q").bytesplice(1..1, "R").append_as_bytes("!")
p s
# a receiver with an effect of its own is evaluated once
a = [String.new("ab"), String.new("cd")]
n = 0
p a[n += 1].append_as_bytes("z"), n, a
p a[n -= 1].bytesplice(0, 1, "Q"), n, a
p a[n += 1].bytesplice(0..0, "R"), n, a
# a variable receiver, a copy, an expression
s = String.new("ab")
p s.append_as_bytes("z"), s
p s.dup.append_as_bytes("y"), s
p (s + "x").append_as_bytes("w"), s
# frozen receivers raise
begin
  "lit".concat("x", "y").append_as_bytes("z")
rescue => e
  p e.class
end
begin
  String.new("ab").freeze.bytesplice(0, 1, "z")
rescue => e
  p e.class
end
