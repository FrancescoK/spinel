# A boxed receiver's call whose methods each answer a String, a shared
# one they hold (Other#method_name's ivar) or a new one (Pattern's `%`),
# keeps the shared one's identity when a local or an argument takes it:
# the String changed through the local is the object's own. The dispatch
# already boxed each arm's answer that way for a container's element;
# into a local or an argument the route was refused as a copy.
class Pattern
  def initialize(prefix)
    @method_name = "#{prefix}%s"
  end

  def method_name(attr)
    @method_name % attr
  end
end

class Other
  def initialize
    @method_name = +"other"
  end

  def method_name(_attr)
    @method_name
  end
end

def define_call(name, as:)
  name << "!"
  p [name, as, name.equal?(as)]
end

def go(pattern, attr)
  method_name = pattern.method_name(attr)
  define_call(method_name, as: method_name)
  converted = pattern.method_name(attr).to_s
  converted << "?"
end

def direct(pattern, attr)
  define_call(pattern.method_name(attr), as: "x")
end

o = Other.new
go(Pattern.new("x_"), "a")
go(o, "b")
p o.method_name(nil)
direct(o, "c")
direct(Pattern.new("y_"), "d")
p o.method_name(nil)
