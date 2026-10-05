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

strings(ARGV.size)
strings(ARGV.size + 1)
shared(ARGV.size)
shared(ARGV.size + 1)
files(ARGV.size)
files(ARGV.size + 1)
