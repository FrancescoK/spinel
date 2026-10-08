# An `if x.is_a?(Array)` on a local whose type settles the answer keeps one
# arm and blanks the other in place (fold_static_is_a), and a builtin's body
# is folded the same way where it is spliced in (flat_map's
# `if v.is_a?(Array)`). The blanked nodes are no longer calls or reads, but
# the list of nodes by kind went on handing them out as such until a node
# was added. The nil analysis then took a read of `out` in the dropped arm
# for one that can run before `out` is written, and every use of `out`
# tested it for nil and raised NoMethodError on a nil it cannot hold.

def gather(v)
  out = []
  if v.is_a?(Array)
    out.concat(v)
  else
    out << v
  end
  out
end
p gather(["a", "b"]).join("-")

def total(v)
  r = [1, 2]
  if v.is_a?(Array)
    r.concat(v)
  else
    r << v
  end
  r.sum
end
p total([3])

def pairs(h)
  h.flat_map { |k, vs| vs.map { |v| "#{k}=#{v}" } }.join("&")
end
p pairs({ "q" => ["ruby", "c"] })
