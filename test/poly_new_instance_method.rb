# A boxed value's `new`: a class constructs, an instance whose class defines
# an instance method `new` calls it (a Thor command named `new`, sent
# by name to whichever CLI instance matched).
class Base
  def initialize(args = [], opts = {})
    @args = args + ["x"]
  end
end
class Sessions < Base
  def new(name) = "new session #{name}"
  def ls = "ls sessions"
end
class Projects < Base
  def add(path) = "add #{path}"
end
def make(k) = k.zero? ? Sessions.new([], {}) : Projects.new([], {})
[[0, "new", ["research"]], [0, "ls", []], [1, "add", ["p"]]].each do |k, n, args|
  inst = make(k)
  p inst.__send__(n, *args)
end
classes = [Sessions, Projects]
classes.each { |k| o = k.new([], {}); p o.class }
