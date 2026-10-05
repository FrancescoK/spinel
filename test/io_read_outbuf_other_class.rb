# The output buffer of read, readpartial, sysread and pread when it is not
# a String: CRuby takes nil as no buffer and any other class through
# StringValue, a TypeError raised after the length converts; a boxed String
# is filled. A longer argument list is ArgumentError. Each of these did not
# build: the arms took every buffer for a String local.
# The length runs, and converts, before the buffer.
require "tmpdir"

def t
  p yield
rescue TypeError, ArgumentError => e
  p [e.class, e.message]
end

path = File.join(Dir.tmpdir, "spinel_io_read_outbuf_other_#{Process.pid}.txt")
File.write(path, "abcdefgh")
f = File.open(path)
i = 1
sym = :s
arr = [1]
fl = 1.5
nb = nil
t { f.readpartial(2, i) }
t { f.sysread(2, sym) }
t { f.read(2, arr) }
t { f.pread(2, 0, fl) }
t { f.read(2, nb) }
t { f.readpartial(2, nb) }
t { f.pread(2, 1, nb) }
k = ARGV.size
bs = [+"zz", 1][k]
t { f.readpartial(2, bs) }
p bs
bi = [1, +"zz"][k]
t { f.sysread(2, bi) }
p bi
bn = [nil, +"zz"][k]
t { f.read(2, bn) }
t { f.pread(3, 2, bs) }
p bs
t { f.readpartial(1, i, i) }
t { f.sysread(1, nb, nb) }
t { f.pread(1, 0, nb, nb) }
rat = 1r
log = []
t { f.readpartial((log << 1; 2), (log << 2; rat)) }
t { f.sysread((log << 3; 2), (log << 4; arr)) }
p log
f.close
File.delete(path)
