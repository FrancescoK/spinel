# A writer called on a receiver of no single type, as the value of a
# method, where one class answers it with `def` and another with
# attr_accessor: the dispatch's value is the argument, and the class
# reached through the fallback arm still has its writer run.

class Plain
  def body=(v)
    @body = v
  end

  def body
    @body
  end
end

class Accessor
  attr_accessor :body
end

def target(i)
  i == 0 ? Plain.new : Accessor.new
end

def assign(i, value)
  target(i).body = value
end

def assign_and_read(i, value)
  t = target(i)
  t.body = value
  t.body
end

p assign(0, "x")
p assign(1, "y")
p assign_and_read(0, "a")
p assign_and_read(1, "b")
