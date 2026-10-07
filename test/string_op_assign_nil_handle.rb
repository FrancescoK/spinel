# `s += x` on a local that shares its String with another name (`t = s`
# with an append through t) goes through String#+: once the operand has
# run, a nil local raises its NoMethodError and a nil operand String's
# TypeError. The local held a NULL handle that the concatenation read, and
# a nil operand was taken for an empty String. Each case has a method and
# locals of its own.
def nil_local
  s = +"a"
  t = s
  t << "q"
  s = nil
  begin
    s += "c"
  rescue NoMethodError => e
    p e.class
  end
  p t
end

def nil_local_effectful_operand
  s = +"a"
  t = s
  t << "q"
  s = nil
  begin
    s += (t << "z"; "c")
  rescue NoMethodError => e
    p e.class
  end
  p t
end

def nil_operand
  s = +"a"
  t = s
  t << "q"
  n = [nil, "x"][0]
  begin
    s += n
  rescue TypeError => e
    p e.class
  end
  p s, t
end

def nothing = nil

def nil_operand_effectful
  s = +"a"
  t = s
  t << "q"
  begin
    s += (t << "z"; nothing)
  rescue TypeError => e
    p e.class
  end
  p s, t
end

nil_local
nil_local_effectful_operand
nil_operand
nil_operand_effectful
