# A method whose value is a call to a user-defined setter answers the
# assignment's value, the argument as written: a parameter that may hold a
# nil Integer is returned with its nil, where the method's own return holds
# one (#8569).
class Box
  def value=(new_value)
    @value = new_value | 0x20
  end

  def value = @value
end

class Holder
  def initialize
    @box = Box.new
  end

  def value=(new_value)
    @box.value = new_value
  end

  def set(v) = @box.value = v

  def box = @box
end

holder = Holder.new
holder.value = [1, 2][1]
p holder.box.value
p holder.set([3, 4][0])
p holder.box.value
holder.value = 2
p holder.box.value
puts "ok"
