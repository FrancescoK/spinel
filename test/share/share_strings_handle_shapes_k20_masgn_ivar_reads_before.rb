# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class K
  def go(s, c)
    @a = +"old"
    @a, @b = (c ? s : +"q"), @a.dup
    @a << "!"
    [@a, @b, s]
  end
end
p K.new.go(+"abc", ARGV.size == 0)
