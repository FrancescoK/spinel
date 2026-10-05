# `case/in` on a String slot that can hold nil: an `in String` (or
# Comparable) pattern does not match the nil, and an `in NilClass` pattern
# does. The roots hold for both. An Array of Strings holds nil the same way,
# so a NilClass element pattern can match one of its elements.
def kind(s)
  case s
  in String => v then [:str, v]
  in NilClass then :nil
  end
end
p kind("a"), kind(nil)

def cmp(s)
  case s
  in Comparable then :cmp
  in Object then :obj
  end
end
p cmp("a"), cmp(nil)

def root(s)
  case s
  in Object then :obj
  end
end
p root("a"), root(nil)

a = ["a", "b"]
a[3] = "c"
r = case a
    in [String, String, NilClass => n, String] then [:gap, n]
    in [String, String, String, String] then :full
    end
p r
r = case a
    in [*, NilClass, *] then :has_nil
    else :no_nil
    end
p r
def pair(t, s)
  case [t, s]
  in [String, String] then :both
  in [String, NilClass] then :second_nil
  end
end
p pair("a", "b"), pair("a", nil)

# An `in nil` pattern matches the nil: alone, after an `in String` arm, and
# in an alternative with String. In an Array or a Hash pattern it matches too.
def innil(s)
  case s
  in nil then :nil
  else :other
  end
end
p innil("a"), innil(nil)

def after(s)
  case s
  in String then :str
  in nil then :nil
  end
end
p after("a"), after(nil)

def bound(s)
  case s
  in String => x then x
  in nil then "default"
  end
end
p bound("a"), bound(nil)

def strnil(s)
  case s
  in String | nil then :str_or_nil
  end
end
p strnil("a"), strnil(nil)

def nilstr(s)
  case s
  in nil | String then :nil_or_str
  end
end
p nilstr("a"), nilstr(nil)

def elem(s)
  case [s, 1]
  in [nil, Integer] then :nil
  in [String, Integer] then :str
  end
end
p elem("a"), elem(nil)

def key(s)
  case {name: s}
  in {name: nil} then :nil
  in {name: String} then :str
  end
end
p key("a"), key(nil)
