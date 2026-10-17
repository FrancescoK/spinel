# A singleton alias of a builtin's class method keeps the builtin when the
# class has an instance alias of the same name made earlier: the check that
# the name was not defined before the alias read the instance aliases for a
# singleton one, took `new` for the program's own, and left `String.mk` with
# no method at run time.
class String
  alias_method :new, :upcase
  class << self
    alias_method :mk, :new
  end
end
p String.mk("x"), "ab".new

class Array
  alias_method :new, :first
  class << self
    alias_method :mk, :new
  end
end
p Array.mk(2, 7), [4, 5].new

# and the other way round: a singleton alias named like an instance builtin
class String
  class << self
    alias_method :swapcase, :new
  end
  alias_method :flip, :swapcase
end
p "aB".flip, String.swapcase("z")
