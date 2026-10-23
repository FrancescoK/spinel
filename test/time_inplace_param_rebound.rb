# A Time parameter changed in place by #localtime and then assigned: the
# change reaches the caller's Time and the assignment does not, as in CRuby.
# (From #9986, where it was refused.)
def m(t)
  t.localtime(3600)
  t = Time.utc(2000, 1, 1)
  t.hour
end

a = Time.utc(2026, 10, 15, 1, 0, 0)
p m(a)
p a.utc_offset
