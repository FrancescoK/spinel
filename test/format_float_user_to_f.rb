# spinel: share
# The Float directives of format, sprintf and String#% convert a user object
# through its #to_f, once per operand.
def show
  p yield
rescue => e
  p [e.class, e.message]
end

class Value
  def to_f
    puts "to_f"
    1.25
  end
end
show { [format("%.1f", Value.new), sprintf("%.1f", Value.new)] }
["%.1f", "%.1e", "%.1E", "%.2g", "%.2G", "%a", "%A"].each do |spec|
  show { format(spec, Value.new) }
end

show { "%.1f" % [Value.new] }
fmt = "%.1f" + "!"
show { fmt % [Value.new] }
show { "%<n>.1f" % {n: Value.new} }

[Value.new, 3, 2.5, Rational(1, 2), "4.5", nil].each do |value|
  begin
    p format("%.1f", value)
  rescue => e
    p [e.class, e.message]
  end
end

class Parent
  def to_f
    puts "parent"
    1.25
  end
end
class Child < Parent
end
show { sprintf("%.1f", Child.new) }

class Bad
  def to_f
    puts "bad to_f"
    2
  end
end
class Raises
  def to_f
    puts "raising to_f"
    raise ArgumentError, "conversion"
  end
end
class Missing
end
[Bad.new, Raises.new, Missing.new].each do |value|
  begin
    p format("%.1f", value)
  rescue => e
    p [e.class, e.message]
  ensure
    puts "ensure"
  end
end

def spec
  puts "spec"
  "%.1f %.1f"
end
def value
  puts "value"
  Value.new
end
show { format(spec, value, value) }
