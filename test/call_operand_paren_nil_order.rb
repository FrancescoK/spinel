# A builtin call runs all its operands, in order, before it converts any
# of them: an argument CRuby cannot convert raises its TypeError only once
# the arguments after it have run. A parenthesized operand, `(log << :a;
# v)`, is ordered like a call's value, and one whose value is nil runs for
# its effect where it stands.

def show(tag, log)
  yield
rescue => e
  puts "#{tag} #{e.class}"
ensure
  puts "#{tag} #{log.inspect}"
end

def t(k)
  log = []
  show("start_with?", log) { p "ab".start_with?((log << :a0; 1), (log << :a1; "x")) }
  log = []
  show("center", log) { p "ab".center((log << :a0; "x"), (log << :a1; "y")) }
  log = []
  s = +"abc"
  show("delete!", log) { p s.delete!((log << :a0; nil), (log << :a1; "a")) }
  log = []
  r = k == 0 ? +"abc" : nil
  show("squeeze!", log) { p (log << :r; r).squeeze!((log << :a0; 7), (log << :a1; "a")) }
  log = []
  a = [3, 1, 2]
  show("first", log) { p (log << :r; a).first((log << :a0; :x)) }
  log = []
  show("fetch", log) { p a.fetch((log << :a0; nil), (log << :a1; 0)) }
  log = []
  show("union", log) { p [1].union((log << :a0; nil), (log << :a1; 2)) }
  log = []
  show("ok", log) { p "abc".delete((log << :a0; "a"), (log << :a1; "ab")) }
end
t(ARGV.size)
