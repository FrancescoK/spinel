class IO
  def self.tag = :io
end

class Box
  def initialize = @a = 1
end

def put(o, name, v) = o.instance_variable_set(name, v)

k = [Box, Box][0]
objs = [k.new, "s", 1]
objs[2].freeze
put(objs[0], :@a, 5)
p objs[0].instance_variable_get(:@a)
p IO.tag
