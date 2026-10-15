# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class H
  def initialize(s, t, c)
    @a, @b = (c ? s : t), s
  end
  def go; @a << "!"; @b << "?"; [@a, @b]; end
end
c = ARGV.size == 0
s = +"abc"
h = H.new(s, +"zz", c)
p h.go, s
