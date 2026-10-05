# A method a program adds to Array, Hash or Random keeps @x on the value
# itself, as CRuby does: reads, writes, ||=, op-assign, defined?, attr
# accessors and the reflection all see one variable per object, in the
# order it was set. An unset one reads nil.

class Array
  attr_accessor :label

  def tag = (@tag ||= :t)
  def count_up = (@n = (@n || 0) + 1)
  def bump(by = 1)
    @n ||= 0
    @n += by
  end
  def known? = defined?(@tag)
  private def secret = @secret
  def reveal = secret
end

class Hash
  def remember(k) = (@seen ||= []) << k
  def seen = @seen
end

class Random
  def set(v) = (@x = v)
  def get = @x
end

a = [1, 2]
b = [1, 2]
p a.tag, a.known?, b.known?
a.count_up
a.count_up
p a.count_up, b.count_up
p a.bump(5), b.bump
a.label = "first"
p a.label, b.label
p a.instance_variables, b.instance_variables
p a.instance_variable_get(:@n), a.instance_variable_defined?(:@label), a.instance_variable_defined?(:@zz)
a.instance_variable_set(:@secret, 42)
p a.reveal, b.reveal
p a == b, a.equal?(b)
p a, a.inspect

h = {k: 1}
h.remember(:a)
h.remember(:b)
p h.seen, {k: 1}.seen, h.instance_variables

r = Random.new(1)
p r.get
p r.set([3, 4])
p r.get, r.instance_variable_get(:@x), Random.new(2).get

ints = [1, 2, 3]
ints << 4
ints.label = :grown
p ints.label, ints.size

s = +"str"
p s.instance_variable_get(:@a), s.instance_variables
