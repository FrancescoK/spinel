# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
c = ARGV.size == 0
s = +"abc"
x = nil
begin
  x, y = (c ? s : +"q"), 1
ensure
  x << "!"
end
p s, x.equal?(s)
