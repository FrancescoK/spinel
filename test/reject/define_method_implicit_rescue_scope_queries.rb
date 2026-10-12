# A define_method block with an implicit rescue is expanded into a def by
# moving its clauses out of the block, with the macro's locals replaced by
# their values. A clause that asks about its own scope or place in the
# source would answer for the def: `defined?(name)` saw an expression where
# CRuby sees a local variable, and `__LINE__` named the expanded line. The
# expansion is refused there.
class Foo
  def self.defined_check(name)
    define_method("#{name}_d") do
      raise "x"
    rescue
      defined?(name)
    end
  end

  def self.line_check(name)
    define_method("#{name}_l") do
      raise "x"
    rescue
      __LINE__
    end
  end

  defined_check :foo
  line_check :bar
end

p Foo.new.foo_d, Foo.new.bar_l
