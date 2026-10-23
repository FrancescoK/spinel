# A Time parameter changed in place by #localtime and captured by a lambda
# that outlives the call: the lambda and the caller hold the one Time, as in
# CRuby. (From #9986, where it was refused.)
def m(t)
  t.localtime(3600)
  -> { t.utc_offset }
end

a = Time.utc(2026, 10, 15, 1, 0, 0)
f = m(a)
p a.utc_offset
p f.call
