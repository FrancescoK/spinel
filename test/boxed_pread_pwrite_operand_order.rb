# pread and pwrite on a receiver that may be nil: the receiver and then
# every argument run before the call raises NoMethodError, as in CRuby
# (pwrite's string ran ahead of the receiver, and the offset never ran).
# On a File they read and write as before, and a missing offset is the
# handle's ArgumentError.
require "tmpdir"

def t
  yield
rescue NoMethodError, TypeError, ArgumentError => e
  puts "#{e.class}: #{e.message}"
end

k = ARGV.size
path = File.join(Dir.tmpdir, "spinel_pwrite_order_#{Process.pid}.txt")
File.write(path, "abcdef")
f = File.open(path, "r+")
log = []
n = [nil, f][k]
t { (log << :r; n).pwrite((log << :a0; nil), (log << :a1; +"s")) }
p log
log.clear
t { (log << :r; n).pread((log << :a0; 3), (log << :a1; 0)) }
p log
log.clear
t { (log << :r; n).pwrite((log << :a0; "x")) }
p log

g = [f, nil][k]
log.clear
p (log << :r; g).pwrite((log << :a0; "XY"), (log << :a1; 2))
p log
p g.pread(4, 1)
p g.pwrite(:sym, 0)
p g.pread(6, 0)
p g.pwrite(12, 4)
t { g.pread(3) }
t { g.pwrite("q") }
# The first operand converts ahead of the offset (pread's length with
# to_int, pwrite's operand with to_s), and a pread buffer is filled.
class Num; def initialize(v, t) = (@v = v; @t = t); def to_int; puts "to_int #{@t}"; @v; end; end
class Txt; def to_s; puts "to_s txt"; "HEY"; end; end
p g.pread(Num.new(3, "len"), Num.new(0, "off"))
p g.pwrite(Txt.new, Num.new(0, "off"))
buf = +"xx"
p g.pread(4, 2, buf)
p buf
f.close
File.delete(path)
