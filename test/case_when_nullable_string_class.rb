# `case` on a String slot that can hold nil: a `when String` (or Comparable)
# arm is String === nil, false, and a `when NilClass` arm matches the nil.
# The roots hold for both. Value and statement forms.
def kind(s)
  case s
  when String then :str
  else :other
  end
end
p kind("a"), kind(nil)

def nilc(s)
  case s
  when NilClass then :nil
  else :other
  end
end
p nilc("a"), nilc(nil)

def cmp(s)
  case s
  when Comparable then :cmp
  else :other
  end
end
p cmp("a"), cmp(nil)

def multi(s)
  case s
  when Integer, String then :is
  else :other
  end
end
p multi("a"), multi(nil)

def root(s)
  case s
  when Object then :obj
  else :other
  end
end
p root("a"), root(nil)

def stmt(s)
  r = :none
  case s
  when String
    r = :str
  when NilClass
    r = :nil
  end
  r
end
p stmt("a"), stmt(nil)

# A `when nil` arm matches the nil: alone, after a `when String` or a
# literal arm, and in a list with String.
def whennil(s)
  case s
  when nil then :nil
  else :other
  end
end
p whennil("a"), whennil(nil)

def strnil(s)
  case s
  when String, nil then :str_or_nil
  else :other
  end
end
p strnil("a"), strnil(nil)

def nilstr(s)
  case s
  when nil, String then :nil_or_str
  else :other
  end
end
p nilstr("a"), nilstr(nil)

def order(s)
  case s
  when String then 1
  when nil then 2
  end
end
p order("a"), order(nil)

def lit(s)
  case s
  when "x" then :x
  when nil then :nil
  else :other
  end
end
p lit("x"), lit(nil), lit("y")
