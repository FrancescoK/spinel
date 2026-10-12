# The clauses of a define_method block with an implicit rescue are moved
# into a def, with the macro's locals replaced by their values. A String or
# Array a macro local holds would be a new literal on every call where CRuby
# keeps one object, and a constant would be looked up from where the def
# lands, not from where the block was written. The expansion is refused
# there.
class Foo
  def self.log(name, buf)
    define_method("#{name}_log") do
      buf << "!"
      buf
    rescue => e
      "rescued #{e.class}"
    end
  end

  log :a, "a" + "b"
end

module Ext
  class MyErr < StandardError; end

  def guarded(name)
    define_method("#{name}_g") do
      raise MyErr, "m"
    rescue MyErr => e
      [e.class.name, name]
    end
  end
end

class Bar
  extend Ext
  guarded :b
end

# a constant the program defines, read from a class reopened under another
# nesting: CRuby finds A::V from the block, the def would find the top V
V = "top"

module A
  V = "a"

  class Baz
    def self.ext(name)
      define_method("#{name}_v") do
        V
      rescue
        nil
      end
    end
  end
end

class A::Baz
  ext :c
end

# a builtin constant read in a module's macro: CRuby looks it up from the
# module, the def from the class, which includes Math
module Pi
  def pi(name)
    define_method("#{name}_pi") do
      PI
    rescue NameError => e
      "r #{e.class}"
    end
  end
end

class Circle
  include Math
  extend Pi
  pi :d
end

p Foo.new.a_log, Foo.new.a_log, Bar.new.b_g, A::Baz.new.c_v, Circle.new.d_pi
