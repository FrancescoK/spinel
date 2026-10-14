# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class K
  def id(t) = t
  def go(s, c)
    pr = ->(q) { q }
    @a, @b, @d, @e = id(s), (c ? s : +"q"), s.then { |q| q }, pr.(s)
    s << "!"
    [@a, @b, @d, @e].map { |x| x.equal?(s) }
  end
end
p K.new.go(+"abc", ARGV.size == 0)
