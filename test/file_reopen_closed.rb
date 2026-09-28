# reopen with a closed File on either side raises IOError, as CRuby does,
# where it answered the receiver.
path = "/tmp/spinel_reopen_closed_#{Process.pid}"
File.write(path, "abc")
f = File.open(path)
g = File.open(path)
f.close
p (f.reopen(g) rescue [$!.class, $!.message])
h = File.open(path)
g.close
p (h.reopen(g) rescue [$!.class, $!.message])
h.close
File.delete(path)
