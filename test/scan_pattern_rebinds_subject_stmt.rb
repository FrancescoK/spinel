# The two String representations refused this program; with one it answers as CRuby.
# The statement form of scan_pattern_rebinds_subject: the check measured
# the local's new String, which the block clears, and raised.
def f(t, acc)
  t.scan((t = +"xy"; /./)) { |m| m << "!"; acc << m; t.clear if acc.size == 1 }
  [acc, t]
rescue RuntimeError => e
  [e.message, acc, t]
end
p f(+"abc", [])
