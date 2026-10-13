# spinel: gc-stress
# A Regexp handed to a lambda or a block rides the proc call's pointer
# slot. Its temp and the parameter were rooted as heap objects, but a
# compiled pattern is no object the collector owns: under
# SPINEL_GC_STRESS=2 the mark walk reached the non-heap pointer and
# aborted.
SRC = ->(re) { re.source }
n = 2
p SRC.call(/b/), SRC.(/c#{n}/)
m = ->(re, s) { re.match?(s) ? "#{s} matches" : "#{s} no" }
p m.call(/x+/, "axxb"), m.call(Regexp.new("q#{n}"), "q2")
def each_pat(pats)
  pats.each { |re| yield re }
end
r = []
each_pat([/a/, /b+/]) { |re| r << "#{re.source}:#{"bbb".scan(re).size}" }
p r
