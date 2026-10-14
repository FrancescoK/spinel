# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class K
  def go(s)
    r = (@a, @b = s.then { |q| q }, 1)
    @a << "!"
    [r.size, @a.equal?(s)]
  end
end
s = +"abc"
p K.new.go(s), s
