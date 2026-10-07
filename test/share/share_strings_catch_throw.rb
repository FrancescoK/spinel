# Flag-only. A catch answers the String or container handed to throw, or
# its block's normal value. Mutating that answer must reach the original
# String, including when a method throws or a tag is known only at runtime.
def caught_string
  s = +"ab"
  t = catch(:plain) { throw :plain, s }
  t << "c"
  p s
  s << "d"
  p t
end

def catch_tail
  s = +"ab"
  t = catch(:tail) { s }
  t << "c"
  p s
end

def throw_from_method(s)
  throw :method_value, s
end

def called_throw
  s = +"ab"
  t = catch(:method_value) { throw_from_method(s) }
  t << "c"
  p s
end

def nested_tags
  s = +"ab"
  t = catch(:outer) do
    catch(:inner) { throw :outer, s }
    +"unreached"
  end
  t << "c"
  p s
end

def shadowed_tag
  s = +"ab"
  t = catch(:same) do
    u = catch(:same) { throw :same, s }
    u << "c"
    u
  end
  t << "d"
  p s
end

def anonymous_tag
  s = +"ab"
  t = catch { |tag| throw tag, s }
  t << "c"
  p s
end

def runtime_tag(tag)
  s = +"ab"
  t = catch(tag) { throw tag, s }
  t << "c"
  p s
end

def caught_array
  s = +"ab"
  a = catch(:array_value) { throw :array_value, [s] }
  a[0] << "c"
  p s
end

def caught_hash
  s = +"ab"
  h = catch(:hash_value) { throw :hash_value, { item: s } }
  h[:item] << "c"
  p s
end

def normal_container
  s = +"ab"
  a = catch(:array_tail) { [s] }
  a[0] << "c"
  p s
end

def caught_expression
  s = +"ab"
  catch(:expression) { throw :expression, s } << "c"
  p s
end

def caught_ensure
  s = +"ab"
  t = catch(:ensured) do
    begin
      throw :ensured, s
    ensure
      s << "c"
    end
  end
  t << "d"
  p s
end

caught_string
catch_tail
called_throw
nested_tags
shadowed_tag
anonymous_tag
runtime_tag(:runtime)
caught_array
caught_hash
normal_container
caught_expression
caught_ensure
