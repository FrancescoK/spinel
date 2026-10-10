# A class method that defines accessors by the names its arguments give,
# called with literal names in the class's own body (or from a module the
# class extends): each call defines the same accessors as the attr_* call
# written out.
module Config
  def self.cattr_accessor name
    (class << self; self; end).attr_accessor name
  end

  def self.cattr_reader(name) = singleton_class.attr_reader(name)

  cattr_accessor :seed
  cattr_accessor :reporter
  cattr_reader :mode

  self.seed = 42
  @mode = "fast"
end

Config.reporter = "dots"
p Config.seed
p Config.reporter
p Config.mode
Config.seed += 1
p Config.seed

class Point
  def self.coord(name)
    attr_accessor name
  end

  coord :x
  coord :y

  def initialize(x, y) = (@x = x; @y = y)
end

pt = Point.new(1, 2)
pt.y = 5
p [pt.x, pt.y]

module Fields
  def field(name)
    attr_reader name
  end
end

class Box
  extend Fields
  field :width

  def initialize(w) = @width = w
end

p Box.new(3).width
