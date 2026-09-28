# IO#gets with no argument answers a line of 64 KB or more whole, as CRuby
# does, where it answered it in 65535-byte pieces; and a NUL inside a line
# neither ends the line nor drops what follows it. IO#readlines with no
# argument reads the same way.
path = "/tmp/spinel_gets_long_#{Process.pid}"
File.write(path, "Q" * 70000 + "\nshort\n" + "R" * 140000)
File.open(path) do |f|
  p f.gets.size
  p f.gets
  p f.gets.size
  p f.gets
end
File.write(path, "a\0b\nc\n")
File.open(path) do |f|
  p f.gets
  p f.gets
  p f.gets
end
File.open(path) { |f| p f.readlines }
File.delete(path)
