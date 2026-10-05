# A write to an IO with several operands (write, print, puts) is lowered to
# one write per operand, and printf formats its operands first: a receiver
# expression with an effect ran once per operand, and printf's ran after its
# operands. CRuby evaluates the receiver once, before the operands.

require "tmpdir"

def t(k)
  log = []
  path = File.join(Dir.tmpdir, "spinel_io_write_receiver_once_#{Process.pid}.txt")
  f = File.open(path, "w")
  (log << :r; f).puts((log << :a0; "x"), (log << :a1; "y"))
  (log << :r2; f).print((log << :b0; "x"), (log << :b1; "y"))
  p((log << :r3; f).write((log << :c0; "x"), (log << :c1; "yz")))
  (log << :r4; f).printf((log << :d0; "%s-%d\n"), (log << :d1; "y"), (log << :d2; 7))
  (log << :r5; f) << (log << :e0; "x")
  (log << :r6; [f, :x][k]).puts((log << :g0; "x"), (log << :g1; "y"))
  f.close
  p log
  p File.read(path)
  File.delete(path)
end
t(ARGV.size)
