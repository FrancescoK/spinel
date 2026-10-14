# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class K
  def initialize(s) = @s = s
  def go = @s.then { |q| q << "!" }
end
s = +"abc"
K.new(s).go
p s
