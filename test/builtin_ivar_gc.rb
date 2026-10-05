# Many short-lived Arrays and Hashes carrying ivars: the runtime's map keeps
# no dead value alive and drops its entry, keeps a live value's ivars (and
# what they hold) through every collection, and an ivar that refers back to
# its own value does not keep it alive.

class Array
  def tag = @tag
  def tag=(v)
    @tag = v
  end
end

class Hash
  def note = @note
  def note!(v) = (@note = v)
end

keep = []
total = 0
2000.times do |i|
  a = [i, i + 1]
  a.tag = "t#{i}"
  h = {i => [i] * 3}
  h.note!(a)
  a.instance_variable_set(:@self_ref, a)
  keep << a if i % 250 == 0
  total += h.note.tag.size + h.note.size
end
GC.start
p total
p keep.map(&:tag)
p keep.map { |a| a.instance_variable_get(:@self_ref).equal?(a) }.uniq
p keep.first.instance_variables

fresh = (1..300).map { |i| [i] }
fresh.each { |a| a.tag = "v#{a[0]}" }
GC.start
p fresh.all? { |a| a.tag == "v#{a[0]}" }
p fresh.last.tag
