# Reopening Struct itself, as activesupport's core_ext/object/json does,
# in a program that never calls Struct.new: no value is a Struct, so what
# the reopening defines has no receiver, and a send with a run-time name
# whose arms cover every class that answers the name must not reach for
# a Struct arm.
class Struct
  def as_json(options = nil)
    to_h.as_json(options)
  end
end

class Hash
  def as_json(options = nil)
    "hash(#{size})"
  end
end

class Object
  def as_json(options = nil)
    "object"
  end
end

class Foo
  def describe
    "foo"
  end
end

class Struct
  def describe
    "struct #{to_a.inspect}"
  end
end

def go(o, m)
  o.__send__(m, nil)
end

[Foo.new, { a: 1 }, 3].each { |o| puts go(o, :as_json) }
m = :describe
[Foo.new, 1].each do |o|
  begin
    puts o.__send__(m)
  rescue NoMethodError
    puts "no describe"
  end
end
puts Foo.new.public_send(:describe)
