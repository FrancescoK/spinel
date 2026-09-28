# An instance_exec/instance_eval block in a class method runs with the
# receiver object as self: its @ivars are that object's, not the class's,
# for a typed and a boxed receiver, a read, a write and an op-write, while
# the class method's own @ivar stays the class-level one. Phlex's SGML.new
# stores the content block this way.
class A
  attr_reader :b, :n
  def self.mk(blk)
    o = A.new
    o.instance_exec { @b = blk }
    o
  end
  def self.count_on(o)
    o.instance_exec { @n = (@n || 0) + 1 }
    o.instance_eval { @n += 10 }
    o
  end
  def self.read(o) = o.instance_exec { @b }
  def self.own
    @own = :class_level
    A.new.instance_exec { @own = :object_level }
    @own
  end
  def own_iv = @own
  def self.poly_set(o)
    o.instance_exec { @b = :poly }
    o
  end
end
class B < A; end
p A.mk(7).b
p A.count_on(A.new).n
p A.read(A.mk(:x))
p A.own
p A.count_on(B.new).n
p A.poly_set([B.new, 1][0]).b
p A.poly_set([A.new, 1][0]).b

class SGML2
  class << self
    def call(...)
      new(...).call
    end

    def new(*a, **k, &block)
      if block
        object = super(*a, **k, &nil)
        object.instance_exec { @_content_block = block }
        object
      else
        super
      end
    end
  end

  def initialize(title = "t", x: 1)
    @title = title
    @x = x
  end

  def call = "#{self.class.name}:#{@title}:#{@x}:#{@_content_block ? @_content_block.call : '-'}"
end

class Page2 < SGML2
  def call = "page " + super
end

p SGML2.call
p Page2.call("hi", x: 2)
p Page2.new("b") { :blk }.call
