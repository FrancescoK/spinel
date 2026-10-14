# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class O; attr_reader :v; end
c = ARGV.size == 0
s = +"abc"
o = O.new
o.instance_variable_set(:@v, (c ? s : +"q"))
s << "!"
p o.v, o.v.equal?(s)
