# A call on a boxed receiver runs its receiver and its arguments before
# the method is looked up, its count checked or an argument converted: a
# receiver of the wrong class, a boxed nil or a wrong count raises only
# once every operand has run, in Ruby's order. The boxed-handle arm of an
# IO method (readpartial) is one such check.

require "tmpdir"

def lg(log, tag, v)
  log << tag
  v
end

def show(tag, log)
  yield
rescue => e
  puts "#{tag} #{e.class}"
ensure
  puts "#{tag} #{log.inspect}"
end

def t(k)
  log = []
  r = [nil, "ab"][k]
  show("nil center", log) { r.center(lg(log, :a0, 5)) }
  log = []
  w = [7, "ab"][k]
  show("int center", log) { w.center(lg(log, :a0, 5), lg(log, :a1, "x")) }
  log = []
  show("paren center", log) { (log << :r; w).center((log << :a0; 5)) }
  log = []
  s = [7, +"ab"][k]
  show("int squeeze!", log) { s.squeeze!((log << :a0; "a")) }
  log = []
  f = [0.3, :x][k]
  show("abs2 count", log) { f.abs2(lg(log, :a0, 1)) }
  log = []
  h = k == 0 ? nil : {1 => 2}
  show("nil compact", log) { (log << :r; h).compact((log << :a0; 1)) }
  log = []
  a = [[1, 2], :x][k]
  show("first count", log) { (log << :r; a).first((log << :a0; 1), (log << :a1; 1)) }
  log = []
  z = [7, [1, 2, 3]][k]
  show("int zip", log) { z.zip(lg(log, :a0, [4]), lg(log, :a1, [5])) }
  log = []
  ok = [+"b", 7][k]
  show("prepend", log) { p ok.prepend((log << :a0; "a"), lg(log, :a1, "c")) }
  log = []
  show("start_with?", log) { p (log << :r; ok).start_with?((log << :a0; "c")) }
  path = File.join(Dir.tmpdir, "poly_recv_args_first_#{Process.pid}.txt")
  File.write(path, "hello")
  f = File.open(path)
  [nil, 7].each do |bad|
    io = [bad, f][k]
    log = []
    show("readpartial #{bad.inspect}", log) { p (log << :r; io).readpartial((log << :a0; 2), (log << :a1; +"")) }
    log = []
    show("readpartial1 #{bad.inspect}", log) { p io.readpartial((log << :a0; 2)) }
  end
  f.close
  File.delete(path)
  # a safe-navigation call on a nil receiver runs no operand
  [nil, +"ab"].each do |v|
    sn = [v, 1][k]
    log = []
    show("safe-nav #{v.inspect}", log) { p (log << :r; sn)&.center((log << :a0; 5)) }
  end
end
t(ARGV.size)
