# The two String representations refused this program; with one it answers as CRuby.
# force_encoding changes the subject in place without changing its length, which the run-time check cannot see.
def c1(t)
  acc = []
  t.scan(/./) { |m| m << "!"; acc << m; t.force_encoding("BINARY") if acc.size == 1 }
  [acc.size, acc[1].bytesize]
rescue RuntimeError => e
  [e.message, acc]
end
p c1(+"aéb")
