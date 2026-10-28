# The record keeps singleton constants separate from the class's constants.
class ParentOwner
  class << self
    A = 1
  end
end
class ChildOwner < ParentOwner
  class << self
    B, C = [2, 3]
    p A, B, C
  end
end
class << ChildOwner
  D = 4
  p D
end
class << self
  E = 5
  p E
end
