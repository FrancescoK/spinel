# A builtin method called on a String or a File that is nil at run time
# raises CRuby's NoMethodError, after the receiver and the arguments have
# run in order. The typed emission read the NULL pointer as the builtin:
# String#to_sym crashed, a mutator raised FrozenError, a File raised
# IOError for a closed stream, an arity check or an argument's conversion
# raised its own error first, and an argument was never run. A method nil
# has itself (to_s, nil?, inspect, ==) still answers as nil does.
require "tmpdir"

def show(tag)
  r = yield
  puts "#{tag} #{r.inspect}"
rescue => e
  puts "#{tag} #{e.class}: #{e.message}"
end

def str_or_nil(k) = k == 0 ? nil : +"ab"
def up(s) = s.upcase

def strings(k)
  log = []
  s = k == 0 ? nil : +"ab"
  show("to_sym") { s.to_sym }
  show("chomp!") { s.chomp!("b") }
  show("start_with?") { s.start_with?(nil) }
  show("casecmp?") { s.casecmp? }
  show("center") { (log << :r; s).center((log << :a0; 5), (log << :a1; "*")) }
  show("log") { log }
  show("call") { str_or_nil(k).to_sym }
  show("param") { up(s) }
  show("to_s") { [s.to_s, s.nil?, s.inspect, s == nil] }
  t = +"cd" if k > 0
  show("unset") { t.upcase }
  u = s&.upcase
  show("safe-nav") { u.size }
  show("stmt") { s << "x"; s }
  show("each_char") { n = 0; s.each_char { |c| n += 1 }; n }
  show("scan") { n = 0; s.scan(/./) { |c| n += 1 }; n }
  up(+"z")
end

def shared(k)
  s = k == 0 ? nil : +"ab"
  t = s
  show("shared") { t << "y"; s << "z"; s }
end

def files(k)
  log = []
  path = File.join(Dir.tmpdir, "nil_builtin_recv_#{Process.pid}.txt")
  f = File.open(path, "w")
  g = k == 0 ? nil : f
  show("puts") { g.puts("x") }
  show("write") { g.write((log << :a0; "y")) }
  show("log") { log }
  show("path") { g.path == path }
  show("print") { g.print "z"; :printed }
  f.close
  File.delete(path)
end

# An argument that is a container literal, a splat, a keyword pair, a
# variable's write, a nil-valued expression, an interpolation or a `||`
# runs ahead of the NoMethodError too, in order.
def operands(k)
  log = []
  s = k == 0 ? nil : +"a,b\nc"
  a = k == 0 ? nil : [1, 2]
  b = k == 0 ? nil : [[1]]
  show("lines") { s.lines(chomp: (log << :l0; true)) }
  show("split") { s.split(*[(log << :s0; ","), (log << :s1; 2)]) }
  show("insert") { a.insert((log << :i0; 0), *[(log << :i1; 7), (log << :i2; 8)]) }
  show("push") { b.push([(log << :b0; 2)], (log << :b1; [3]), [[(log << :b2; 4)].first]) }
  show("nilarg") { s.split((log << :n0; nil), (log << :n1; 2)) }
  show("interp") { s.split("#{log << :d0}", (log << :d1; 2)) }
  show("or") { s.ljust((log << :e0; 9), (log << :e1; "*") || (log << :no; "-")) }
  show("log") { log }
  w = 0
  pad = nil
  begin
    puts "writes #{s.center(w += 6, pad ||= "*").inspect}"
  rescue NoMethodError => e
    puts "writes #{e.message}"
  end
  show("written") { [w, pad] }
end

# A boxed receiver (a value a method widened to any class) without the
# method raises after its receiver and its arguments have run, in that
# order, whichever class it holds; `&.` on nil runs none. An operator or
# an index hands its operand to the runtime, which runs it first too.
def boxed_of(x) = x

def boxed(k)
  log = []
  n = boxed_of(k == 0 ? nil : 5)
  boxed_of("a,b")
  show("boxed") { n.split((log << :p0; nil)) }
  show("boxed2") { n.start_with?((log << :p1; "a"), (log << :p2; "b")) }
  show("boxed3") { boxed_of(n).split((log << :p3; ","), (log << :p4; 2)) }
  show("boxed-block") { n.each_line((log << :p5; nil)) { |l| log << :no } }
  show("safe-nav") { n&.split((log << :p6; nil)) }
  show("log") { log }
  log.clear
  show("interp") { boxed_of((log << :r0; n)).split("#{log << :a0}", (log << :a1; 2)) }
  show("or") { boxed_of((log << :r1; n)).split((log << :a2; ",") || (log << :no; "-")) }
  show("and") { boxed_of((log << :r2; n)).split(log && (log << :a3; ",")) }
  show("begin") { boxed_of((log << :r3; n)).split(begin; log << :a4; ","; end) }
  show("op") { [n + (log << :a5; 1), n[(log << :a6; 0)]] }
  show("log") { log }
end

strings(ARGV.size)
strings(ARGV.size + 1)
operands(ARGV.size)
operands(ARGV.size + 1)
boxed(ARGV.size)
boxed(ARGV.size + 1)
shared(ARGV.size)
shared(ARGV.size + 1)
files(ARGV.size)
files(ARGV.size + 1)
