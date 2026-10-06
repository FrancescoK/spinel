# force_encoding on a String that is a shared handle (#6179) changes the
# handle's encoding. The ASCII-8BIT tag lives on the handle and is stamped
# back into its bytes after every growth; it was set on the bytes alone, so
# a handle local or ivar -- whose read is a copy -- tagged the copy, and a
# handle in a poly slot lost the tag at the next append that moved its
# bytes.

pr = proc { |t| t << "!" }
s = +"héllo"
pr.call(s)
r = s.force_encoding("ASCII-8BIT")
p s.encoding == Encoding::BINARY, s.size, r.size
s << "y" * 300
p s.encoding == Encoding::BINARY, s.size
s.force_encoding(Encoding::UTF_8)
p s.encoding == Encoding::UTF_8, s.size
s << "z" * 300
p s.encoding == Encoding::UTF_8, s.size

class H
  def initialize; @s = +"héllo"; end
  def run
    t = @s; t << "!"
    @s.force_encoding("BINARY")
    p @s.encoding == Encoding::BINARY, @s.size, t.size
    @s.force_encoding("UTF-8")
    p @s.size
  end
end
H.new.run

# a handle in a poly slot keeps the tag through an append that grows it
pb = proc { |t| t << "!"; t.force_encoding("BINARY"); t << "x" * 300; [t.encoding == Encoding::BINARY, t.size] }
u = +"héllo"
p pb.call(u), u.encoding == Encoding::BINARY, u.size

def app(x) = x << "!"
arr = [+"héllo"]
app(arr[0])
arr[0].force_encoding(Encoding::BINARY)
arr[0] << "z" * 300
p arr[0].encoding == Encoding::BINARY, arr[0].size

# a frozen handle refuses, as a frozen String does
f = +"fr"
pr.call(f)
f.freeze
begin; f.force_encoding("BINARY"); rescue FrozenError => e; p e.class; end
p f.encoding == Encoding::UTF_8
