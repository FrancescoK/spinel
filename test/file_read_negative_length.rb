# File#read with a negative length raises ArgumentError, as CRuby does,
# where it read the rest of the file.
path = "/tmp/spinel_read_neg_#{Process.pid}"
File.write(path, "abcdef")
f = File.open(path)
p (f.read(-1) rescue [$!.class, $!.message])
p (f.read(-5) rescue [$!.class, $!.message])
p f.read(2)
p f.read(3)
f.close
# the length is checked before the stream, so a closed File says so too
p (f.read(-1) rescue [$!.class, $!.message])
File.delete(path)
