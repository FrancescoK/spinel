class Holder
  def initialize(v)
    @v = v
  end

  def instance?(cls)
    @v.instance_of?(cls)
  end

  def kind?(cls)
    @v.is_a?(cls)
  end
end

def instance?(v, cls)
  v.instance_of?(cls)
end

p Holder.new([1, 2, 3].each).instance?(Enumerator)
p Holder.new([1, 2, 3].map).instance?(Enumerator)
p Holder.new([1, 2, 3].each).kind?(Enumerable)
p Holder.new(1).instance?(Enumerator)
p instance?([1, 2].each_slice(1), Enumerator)
p instance?(1, Integer)
p instance?("a", Enumerator)
p [[1].each, 1].grep(Enumerator).size
