# super(&nil) and super(&proc) into a yielding parent replace the caller's
# own block, also from a method that holds its block as a proc; a long
# forwarded proc expression is passed whole.
class Base
  def each_twice
    if block_given?
      yield 1
      yield 2
    end
    :done
  end
end
PRIMARY = proc { |x| puts "primary #{x}" }

class NilArg < Base
  def each_twice(&blk)
    @b = blk
    yield 0
    super(&nil)
  end
end
p NilArg.new.each_twice { |x| p x }

class ProcArg < Base
  def each_twice(&blk)
    @b = blk
    yield 0
    super(&PRIMARY)
  end
end
p ProcArg.new.each_twice { |x| p x }

class AnonNil < Base
  def each_twice(&) = super(&nil)
end
p AnonNil.new.each_twice { |x| p x }

class LongForwardedProcExpression < Base
  def the_handler_this_override_forwards_to_its_yielding_parent_instead_of_its_own_block = PRIMARY
  def each_twice(&) = super(&the_handler_this_override_forwards_to_its_yielding_parent_instead_of_its_own_block)
end
p LongForwardedProcExpression.new.each_twice { |x| puts "ignored #{x}" }
