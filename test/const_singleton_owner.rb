# Singleton bodies keep their own constants and read enclosing scopes first.
def value = 1
class << self
  MAIN_VALUE = value
  p MAIN_VALUE
end

module OuterOwner
  LEXICAL_VALUE = 2
  class Parent
    class << self
      PARENT_VALUE = 3
    end
  end
  class Child < Parent
    class << self
      OWN_VALUE = 4
      p OWN_VALUE
      p LEXICAL_VALUE
      p PARENT_VALUE
    end
  end
end

class << OuterOwner::Child
  PATH_VALUE = 5
  p PATH_VALUE
end
