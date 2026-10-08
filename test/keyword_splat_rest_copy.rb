# A `**h` that degrades into a *rest's tail is a new Hash of h's keywords,
# as CRuby passes, not h itself: a store into it leaves h alone. The copy
# allocates before it reads its source, so a source the call built
# (`**mk(i)`) is rooted while it waits; run under SPINEL_GC_STRESS (see
# GC_MINOR_TESTS) a collection there swept it and the copy read freed
# memory. The positional and post-rest bindings copy the same way.
# spinel: gc-minor
def rs(*r) = r
def opt(a, b = nil) = [a, b]
def post(*r, z) = [r, z]
def mk(i) = { k: "v#{i}", w: [i, i + 1] }

h = { k: 1 }
x = rs(1, **h)
p x[1].equal?(h)
x[1][:z] = 2
p h
p rs(1, **h, **{}).last.equal?(h)
e = {}
p rs(1, **e)
p rs(1, **nil)

out = []
100.times do |i|
  a = rs(i, **mk(i)).last
  b = opt(i, **mk(i))[1]
  c = post(i, **mk(i))[1]
  out << "#{a[:k]}#{a[:w].sum}/#{b[:k]}#{b[:w].sum}/#{c[:k]}#{c[:w].sum}"
end
p out.size, out.uniq.size, out[0], out[99]
