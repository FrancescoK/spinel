# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class K
  def set(s, c)
    @a, @b = (c ? s : +"q"), 1
  end
  attr_reader :a
end
s = +"abc"
k = K.new
k.set(s, ARGV.size == 0)
k.a << "!"
p s, k.a.equal?(s)
