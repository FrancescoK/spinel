# The two String representations refused this program; with one it answers as CRuby.
# A scan whose pattern rebinds the subject's local: the run-time check
# measured the local's new String, which the block grows, where CRuby
# scans the String the local held and raises for no change to it. The
# value form's check read a temp declared after it, and the C did not
# build.
def f(t, acc)
  r = t.scan((t = +"xy"; /./)) { |m| m << "!"; acc << m; t << "q" if acc.size == 1 }
  [acc, t, r]
rescue RuntimeError => e
  [e.message, acc, t]
end
p f(+"abc", [])
