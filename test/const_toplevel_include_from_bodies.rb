# The constants of a module the top level includes are visible from every
# body, as Object is the last ancestor of each lookup: a method of a class and
# a top-level method both read them, while the colliding name keeps its own
# value under its own path.
module Units
  Scale = 10
  module Metric
    Scale = 1000
  end
end

include Units::Metric

class Converter
  def factor = Scale
end

def top_factor = Scale

p Converter.new.factor
p top_factor
p Units::Scale
