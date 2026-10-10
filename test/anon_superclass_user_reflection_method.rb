# A class whose superclass is an anonymous class leaves `superclass` and
# `ancestors` refused where they can reach it. A user object's own method of
# that name is not Class#superclass, so asking it stays allowed: RDoc's
# ClassModule#superclass beside `class Rule < Struct.new(:weight)`.
class Rule < Struct.new(:weight)
end

class Mod
  def initialize(name, sup)
    @name = name
    @sup = sup
  end

  def superclass
    @sup
  end

  def ancestors
    superclass ? [@name] + superclass.ancestors : [@name]
  end

  def describe
    "#{@name} < #{superclass ? superclass.ancestors.join(",") : "none"}"
  end
end

base = Mod.new("Base", nil)
kid = Mod.new("Kid", base)
p kid.superclass.ancestors
p kid.ancestors
puts kid.describe
puts base.describe
p Rule.new(3).weight

# a boxed receiver: two user classes behind one name
class Other
  def superclass
    "other's"
  end
end
[kid, Other.new, base].each { |m| p m.superclass.is_a?(Mod) ? m.superclass.ancestors : m.superclass }
