# An attr_* in `class << Const` declares accessors on the class the constant
# names, at the top level and in another class's body (not on the class
# whose body it sits in).
class Other; end
class Third; end
class << Other
  attr_accessor :conf
end
class Host
  class << Third
    attr_reader :level
  end
  class << self
    attr_accessor :own
  end
end
Other.conf = 3
p Other.conf
p Third.level
Host.own = :o
p Host.own, Host.respond_to?(:level), Third.respond_to?(:own)
