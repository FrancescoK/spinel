# A `class << self; attr_writer :x` with no reader still has a slot of its
# own: the setter stores into it (a class method reads it back as @x).
class Cfg
  class << self
    attr_writer :level
    attr_writer :label
    def level_or(d) = @level || d
  end
end
p Cfg.level_or(1)
Cfg.level = 3
p Cfg.level_or(1)
Cfg.label = "x"
p Cfg.respond_to?(:label=), Cfg.respond_to?(:label)
