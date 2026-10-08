# Flag-only: a shared reader keeps its identity through yield.
# Both the answer and its source observe in-place changes.

class FrozenReader
  attr_accessor :value
  def relay = yield
  def run
    self.value = "abc"
    got = relay { self.value }
    p self.value.equal?(got), self.value.object_id == got.object_id
    p self.value.frozen?, got.frozen?
    begin
      got.insert(0, "w")
    rescue FrozenError => e
      p e.class
    end
    p [self.value, got]
    begin
      self.value << "!"
    rescue FrozenError => e
      p e.class
    end
    p [self.value, got]
  end
end
FrozenReader.new.run

class MutableReader
  attr_reader :value
  def relay = yield
  def run
    @value = +"abc"
    got = relay { self.value }
    p self.value.equal?(got), self.value.object_id == got.object_id
    p self.value.frozen?, got.frozen?
    begin
      got.insert(0, "w")
    rescue FrozenError => e
      p e.class
    end
    p [self.value, got]
    begin
      @value << "!"
    rescue FrozenError => e
      p e.class
    end
    p [self.value, got]
  end
end
MutableReader.new.run
