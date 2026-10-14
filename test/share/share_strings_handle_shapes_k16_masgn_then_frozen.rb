# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
c = ARGV.size == 0
s = +"abc"
x, y = "lit".then { |q| q }, (c ? s : "lit2")
begin
  y << "!"
rescue FrozenError => e
  p e.class
end
p s, x, y.equal?(s)
