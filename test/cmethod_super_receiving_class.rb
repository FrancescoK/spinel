# A class method a subclass inherits, reached through `super` or called on
# the subclass directly, runs with self the subclass: its bare `new`
# builds the subclass (#5995).
class Base
  attr_reader :ref
  def initialize(ref)
    @ref = ref
  end

  def self.parse(s)
    new(s)
  end
end

class Sub < Base
  def self.parse(s)
    doc = super(s)
    doc
  end
end

class Tagged < Base
  attr_reader :tag
  def initialize(ref, tag = :t)
    super(ref)
    @tag = tag
  end
end

class Deep < Sub; end

p Base.parse("a").class
p Sub.parse("b").class
p Tagged.parse("c").class
p Tagged.parse("c").tag
p Deep.parse("d").class
p Sub.parse("e").ref
