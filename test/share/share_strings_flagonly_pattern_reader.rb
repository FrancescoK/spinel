# spinel: int64
# Flag-only: a pattern's reader element carries the backing String handle
# and its frozen mark. Mutating either name observes that same object.
class PatternReader
  attr_accessor :value

  def read = @value

  def frozen_value
    self.value = "abc"
    case [self.value]
    in [t]
    end
    p [self.value.frozen?, t.frozen?]
    begin
      self.value.insert(0, "x")
    rescue => e
      puts e.class
    end
    p [self.value.frozen?, t.frozen?]
    p [self.value, t]
  end

  def mutable_value
    self.value = +"abc"
    case [self.read]
    in [t]
    end
    t << "!"
    p [self.read, t]
    p [self.read.equal?(t), self.read.object_id == t.object_id]
  end
end
x = PatternReader.new
x.frozen_value
x.mutable_value
