# spinel: share
# spinel: gc-stress
# A String Range's % is its step, and the Enumerator it answers inspects with
# the name it was called by: `%(2)`, where step answers `step(2)`. The call was
# renamed to step before its row was picked, so it inspected as step(2).
r = ("a".."e")
p r % 2
puts (r % 2).inspect
p r.step(2)
p ("a"..."e") % 2
n = 3
e = r % n
p e, e.to_a
p((r % 2).map(&:upcase))
p((r % 2).first(2))
x = ("a".."z") % 5
p x.next, x.next
# the block form is the step, as before
(r % 2).each { |s| print s }
puts
r.%(2) { |s| print s }
puts
r.step(2) { |s| print s }
puts
def stride(rng, k) = rng % k
p stride(r, 2), stride(("x".."z"), 1).to_a
# a Float stride is only a label: CRuby builds the Enumerator and raises
# TypeError from its walk, whatever reads it; its size is nil
def attempt
  yield
rescue TypeError => e
  puts "TypeError: #{e.message}"
end
f = 1.5
p r % f, r % 2.0, r.step(0.5), ("a"..."e") % -1.5
fe = r % f
p fe.size
attempt { p fe.to_a }
attempt { p fe.next }
attempt { p fe.first(2) }
attempt { fe.each { |s| print s } }
attempt { p fe.each_with_index.to_a }
attempt { r.step(f) { |s| print s } }
attempt { r.%(f) { |s| print s } }
# a stride only known at run time takes the same road
p stride(r, 2).to_a
p stride(r, 1.5)
attempt { p stride(r, 1.5).to_a }
