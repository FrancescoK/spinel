# A constant assigned inside `class << self` is assigned where the body
# runs, so the singleton methods beside it read its value, not nil (#5996).
module Scrub
  class << self
    TABLE = { "<" => "&lt;" }
    LIST = ["a", "b"]
    NAME = "scrub"
    SIZE = LIST.size + 1

    def show
      p TABLE
      p LIST
      p NAME
      p SIZE
      p "x<y".gsub(/</, TABLE)
    end
  end
end
Scrub.show

class Registry
  class << self
    DEFAULTS = [1, 2, 3]
    def total = DEFAULTS.sum
  end
end
p Registry.total
