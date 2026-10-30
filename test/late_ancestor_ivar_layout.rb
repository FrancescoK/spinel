# An ivar a base class gains after its subclasses laid out their own slots
# must not share a slot with a subclass's own ivar. The receiver of the
# instance_variable_set below is a local of an `inherited` hook no subclass
# reaches: its type stays unknown through the inference and is widened to a
# boxed value only at the end, after the inherited slots were merged, so the
# late slot was appended to Base alone, at the index Kid's @value already
# had, and the compiler refused the program over its own layout.
class Base
  def hello
    "hi"
  end
end

class Kid < Base
  def initialize(v)
    @value = v
  end

  def value
    @value
  end
end

class ID
  def self.inherited(klass)
    k = klass.ancestors.find { |kl| kl.respond_to?(:superclass) && kl.superclass == ID }
    unless k.instance_variable_defined?(:@_warned)
      warn "deprecated #{k}"
      k.instance_variable_set(:@_warned, true)
    end
    super
  end
end

puts Kid.new(3).value
puts Kid.new(4).hello

# An ivar set on a Class object through a boxed receiver is the class's own,
# not a slot of its instances' layout.
def mark(k)
  k.instance_variable_set(:@marked, true) unless k.instance_variable_defined?(:@marked)
  k.instance_variable_get(:@marked)
end

[Kid, Base].each { |x| p mark(x) }
p Kid.instance_variable_get(:@marked)
p Base.instance_variable_get(:@marked)
p Kid.new(5).instance_variables
p Base.new.instance_variables
