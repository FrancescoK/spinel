# A program's `deconstruct_keys(*)` takes the keys a hash pattern asks for
# as its rest's one element, on a class's instance and on an Object.new's
# singleton method alike (rubyspec language/pattern_matching 088, 089).
class Foo
  def deconstruct_keys(*args)
    $seen = args
    { a: 1 }
  end
end

class Bar
  def deconstruct_keys(*)
    { "a" => 1 }
  end
end

r = case Foo.new
    in { a: 1 } then true
    else false
    end
p r
p $seen

r = case Bar.new
    in Bar[a: 1] then true
    else false
    end
p r

obj = Object.new
def obj.deconstruct_keys(*)
  { "a" => 1 }
end
r = case obj
    in Object[a: 1] then true
    else false
    end
p r

two = Object.new
def two.deconstruct_keys(*)
  { a: 2 }
end
p((two in { a: 2 }))
