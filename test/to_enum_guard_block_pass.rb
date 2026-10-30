# A method guarded by `return to_enum(:m) unless block_given?` whose block
# form answers self: with a proc value (`&pr`) or a &block held as a value,
# whether there is a block is decided at run time, so the call answers the
# Enumerator or the receiver, each as it is.
class Params
  def initialize(h)
    @parameters = h
  end

  def each_value(&block)
    return to_enum(:each_value) unless block_given?
    @parameters.each_pair do |key, value|
      yield value
    end

    self
  end
end

class Held
  def initialize(h)
    @parameters = h
  end

  def each_value(&block)
    return to_enum(:each_value) unless block
    @parameters.each_pair do |key, value|
      block.call(value)
    end

    self
  end
end

pr = proc { |v| puts v }
p = Params.new({a: 1, b: 2})
puts p.each_value(&pr).class
puts p.each_value.class
puts p.each_value { |v| puts v * 10 }.class
puts p.each_value(&nil).class

h = Held.new({c: 3, d: 4})
puts h.each_value(&pr).class
puts h.each_value.class
puts h.each_value { |v| puts v * 10 }.class
